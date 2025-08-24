#!/bin/bash
# FeedbackBin VPS Setup Script
# Run this on a fresh Ubuntu 24.04 server as root

set -e

echo "=== FeedbackBin VPS Setup Script ==="
echo "This script will configure your VPS for Kamal deployment"
echo ""

# Variables (modify as needed)
DEPLOY_USER="deploy"
SSH_PORT="2222"
TIMEZONE="UTC"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   print_error "This script must be run as root"
   exit 1
fi

# Update system
print_status "Updating system packages..."
apt update && apt upgrade -y

# Install essential packages
print_status "Installing essential packages..."
apt install -y \
    curl \
    git \
    vim \
    htop \
    ufw \
    fail2ban \
    unattended-upgrades \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    net-tools \
    wget

# Set timezone
print_status "Setting timezone to $TIMEZONE..."
timedatectl set-timezone $TIMEZONE

# Create deploy user
print_status "Creating deploy user..."
if ! id "$DEPLOY_USER" &>/dev/null; then
    adduser --disabled-password --gecos "" $DEPLOY_USER
    usermod -aG sudo $DEPLOY_USER
    print_status "Deploy user created"
else
    print_warning "Deploy user already exists"
fi

# Set up SSH directory for deploy user
print_status "Setting up SSH for deploy user..."
mkdir -p /home/$DEPLOY_USER/.ssh
chmod 700 /home/$DEPLOY_USER/.ssh

# Copy authorized_keys from root if exists
if [ -f /root/.ssh/authorized_keys ]; then
    cp /root/.ssh/authorized_keys /home/$DEPLOY_USER/.ssh/
    print_status "SSH keys copied to deploy user"
else
    print_warning "No SSH keys found in /root/.ssh/authorized_keys"
    print_warning "Please add your public key to /home/$DEPLOY_USER/.ssh/authorized_keys"
fi

chown -R $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/.ssh
chmod 600 /home/$DEPLOY_USER/.ssh/authorized_keys 2>/dev/null || true

# Configure sudoers for passwordless sudo
print_status "Configuring passwordless sudo for deploy user..."
echo "$DEPLOY_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$DEPLOY_USER
chmod 440 /etc/sudoers.d/$DEPLOY_USER

# Install Docker
print_status "Installing Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com | sh
    usermod -aG docker $DEPLOY_USER
    systemctl enable docker
    systemctl start docker
    print_status "Docker installed successfully"
else
    print_warning "Docker already installed"
    usermod -aG docker $DEPLOY_USER
fi

# Configure SSH
print_status "Configuring SSH security..."
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

cat > /etc/ssh/sshd_config.d/99-feedbackbin.conf << EOF
# FeedbackBin SSH Configuration
Port $SSH_PORT
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
AllowUsers $DEPLOY_USER
X11Forwarding no
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
Compression delayed
UsePAM yes
EOF

print_status "SSH configured on port $SSH_PORT"

# Configure UFW Firewall
print_status "Configuring firewall..."
ufw --force disable
ufw default deny incoming
ufw default allow outgoing
ufw allow $SSH_PORT/tcp comment 'SSH'
ufw allow 22/tcp comment 'SSH fallback (temporary)'
ufw allow 80/tcp comment 'HTTP'
ufw allow 443/tcp comment 'HTTPS'
ufw --force enable
print_status "Firewall configured"

# Configure Fail2ban
print_status "Configuring Fail2ban..."
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
destemail = root@localhost
sendername = Fail2Ban
action = %(action_mwl)s

[sshd]
enabled = true
port = $SSH_PORT,22
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 7200
EOF

systemctl enable fail2ban
systemctl restart fail2ban
print_status "Fail2ban configured"

# Configure automatic security updates
print_status "Configuring automatic security updates..."
cat > /etc/apt/apt.conf.d/50unattended-upgrades << EOF
Unattended-Upgrade::Allowed-Origins {
    "\${distro_id}:\${distro_codename}-security";
    "\${distro_id}ESMApps:\${distro_codename}-apps-security";
    "\${distro_id}ESM:\${distro_codename}-infra-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "02:00";
EOF

cat > /etc/apt/apt.conf.d/20auto-upgrades << EOF
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF

systemctl enable unattended-upgrades
print_status "Automatic security updates configured"

# Set up swap file (2GB)
print_status "Setting up swap file..."
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    print_status "2GB swap file created"
else
    print_warning "Swap file already exists"
fi

# Configure sysctl for better performance
print_status "Optimizing system parameters..."
cat > /etc/sysctl.d/99-feedbackbin.conf << EOF
# Network optimizations
net.core.somaxconn = 65535
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.ip_local_port_range = 10000 65000

# Memory optimizations
vm.swappiness = 10
vm.dirty_ratio = 15
vm.dirty_background_ratio = 5
EOF

sysctl -p /etc/sysctl.d/99-feedbackbin.conf
print_status "System parameters optimized"

# Create backup directory
print_status "Creating backup directory..."
mkdir -p /home/$DEPLOY_USER/backups
chown $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/backups

# Create backup script
print_status "Creating backup script..."
cat > /home/$DEPLOY_USER/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/home/deploy/backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
CONTAINER_NAME="feedbackbin-web"

# Create backup directory
mkdir -p $BACKUP_DIR

# Check if container exists
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    # Backup SQLite database and storage
    docker exec $CONTAINER_NAME tar -czf - /rails/db/production.sqlite3 /rails/storage 2>/dev/null > $BACKUP_DIR/backup-$TIMESTAMP.tar.gz
    
    if [ $? -eq 0 ]; then
        echo "Backup created: backup-$TIMESTAMP.tar.gz"
        
        # Keep only last 7 days of backups
        find $BACKUP_DIR -name "backup-*.tar.gz" -mtime +7 -delete
    else
        echo "Backup failed"
        rm -f $BACKUP_DIR/backup-$TIMESTAMP.tar.gz
    fi
else
    echo "Container $CONTAINER_NAME not found"
fi
EOF

chmod +x /home/$DEPLOY_USER/backup.sh
chown $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/backup.sh

# Add backup cron job
print_status "Setting up automated backups..."
(crontab -u $DEPLOY_USER -l 2>/dev/null; echo "0 2 * * * /home/$DEPLOY_USER/backup.sh >> /home/$DEPLOY_USER/backups/backup.log 2>&1") | crontab -u $DEPLOY_USER -

# Install monitoring tools
print_status "Installing monitoring tools..."
apt install -y netdata
systemctl enable netdata
systemctl start netdata

# Restart SSH service
print_status "Restarting SSH service..."
systemctl restart sshd

# Create setup completion file
cat > /home/$DEPLOY_USER/setup_complete.txt << EOF
=== FeedbackBin VPS Setup Complete ===

Server Details:
- Deploy User: $DEPLOY_USER
- SSH Port: $SSH_PORT
- Firewall: Enabled (ports 22, $SSH_PORT, 80, 443)
- Fail2ban: Enabled
- Docker: Installed
- Automatic Updates: Enabled
- Swap: 2GB
- Backups: Daily at 2 AM
- Monitoring: Netdata (http://YOUR_IP:19999)

Next Steps:
1. Test SSH connection: ssh -p $SSH_PORT $DEPLOY_USER@YOUR_IP
2. Remove temporary SSH port 22 access: sudo ufw delete allow 22/tcp
3. Deploy application with Kamal
4. Set up domain DNS records
5. Monitor logs: sudo journalctl -f

Security Notes:
- Root login is disabled
- Password authentication is disabled
- Only $DEPLOY_USER can SSH
- Fail2ban is monitoring SSH attempts
- Automatic security updates are enabled

Backup Location: /home/$DEPLOY_USER/backups/
Backup Script: /home/$DEPLOY_USER/backup.sh
EOF

chown $DEPLOY_USER:$DEPLOY_USER /home/$DEPLOY_USER/setup_complete.txt

print_status "============================================"
print_status "VPS Setup Complete!"
print_status "============================================"
echo ""
print_warning "IMPORTANT: SSH port has been changed to $SSH_PORT"
print_warning "Test the new SSH connection before closing this session:"
echo ""
echo "  ssh -p $SSH_PORT $DEPLOY_USER@$(curl -s ifconfig.me)"
echo ""
print_warning "Once confirmed working, remove temporary port 22 access:"
echo "  sudo ufw delete allow 22/tcp"
echo ""
print_status "Setup details saved to: /home/$DEPLOY_USER/setup_complete.txt"