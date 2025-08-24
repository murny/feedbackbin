# FeedbackBin Deployment Plan - 2025

## Current Setup Audit

### ✅ What's Already Configured
- **Kamal Configuration**: `config/deploy.yml` exists with basic setup
- **Docker Setup**: Dockerfile configured for Rails 8 with Thruster
- **GitHub Actions**: Workflow exists but is currently disabled
- **Domain**: feedbackbin.com configured in Kamal
- **Registry**: Docker Hub (username: murny)
- **Ruby Version**: 3.4.5
- **Rails Version**: Edge (main branch)
- **Database**: SQLite with persistent volume
- **Background Jobs**: Solid Queue configured to run in Puma

### ⚠️ Issues Found
1. **Kamal not installed locally** - Need to install latest version
2. **GitHub Actions disabled** - Deploy step commented out
3. **Hardcoded IP address** - Using 143.198.37.164 (should verify if still valid)
4. **No SSH user configuration** - Using root by default (security risk)
5. **No backup strategy** - SQLite volume needs backup plan
6. **Missing environment variables** - No .env.example file

## Deployment Plan

### Phase 1: Local Environment Setup

#### 1.1 Install/Update Kamal
```bash
# Install latest Kamal (2.x)
gem install kamal

# Verify installation
kamal version

# Add to Gemfile if not present (already in your Gemfile)
bundle install
```

#### 1.2 Create Environment Files
Create `.env.example` for documentation:
```bash
# Docker Registry
KAMAL_REGISTRY_PASSWORD=your_dockerhub_token

# Rails
RAILS_MASTER_KEY=contents_of_config/master.key

# Optional: Domain configuration
APP_DOMAIN=feedbackbin.com
```

### Phase 2: VPS Setup & Hardening

#### 2.1 Provision DigitalOcean Droplet
- **Size**: Start with 2GB RAM / 1 vCPU ($12/month)
- **OS**: Ubuntu 24.04 LTS
- **Region**: Choose closest to target audience
- **Add SSH key during creation**

#### 2.2 Initial Server Setup
```bash
# Connect as root initially
ssh root@YOUR_SERVER_IP

# Update system
apt update && apt upgrade -y

# Install essential packages
apt install -y curl git vim ufw fail2ban unattended-upgrades

# Create deploy user
adduser deploy
usermod -aG sudo deploy
usermod -aG docker deploy

# Set up SSH for deploy user
su - deploy
mkdir ~/.ssh
chmod 700 ~/.ssh
# Copy your public key to authorized_keys
exit

# Copy SSH key from root
cp /root/.ssh/authorized_keys /home/deploy/.ssh/
chown -R deploy:deploy /home/deploy/.ssh
```

#### 2.3 Security Hardening

**SSH Configuration:**
```bash
# Edit /etc/ssh/sshd_config
nano /etc/ssh/sshd_config

# Add/modify these settings:
Port 2222                    # Change default port
PermitRootLogin no           # Disable root login
PasswordAuthentication no    # Force key-based auth
PubkeyAuthentication yes
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
AllowUsers deploy            # Only allow deploy user

# Restart SSH
systemctl restart sshd
```

**Firewall Setup:**
```bash
# Configure UFW
ufw default deny incoming
ufw default allow outgoing
ufw allow 2222/tcp  # SSH on custom port
ufw allow 80/tcp    # HTTP
ufw allow 443/tcp   # HTTPS
ufw allow 22/tcp    # Temporary for Kamal (remove later)
ufw --force enable
```

**Fail2Ban Configuration:**
```bash
# Create custom jail configuration
cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
port = 2222
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
EOF

systemctl restart fail2ban
```

**Automatic Updates:**
```bash
# Configure unattended-upgrades
dpkg-reconfigure -plow unattended-upgrades

# Edit /etc/apt/apt.conf.d/50unattended-upgrades
# Enable security updates only
```

#### 2.4 Install Docker
```bash
# Install Docker (as deploy user)
curl -fsSL https://get.docker.com | sh

# Verify Docker installation
docker --version
docker compose version
```

### Phase 3: Kamal Configuration Updates

Update `config/deploy.yml`:

```yaml
# Name of your application
service: feedbackbin

# Container image
image: murny/feedbackbin

# Deploy to these servers
servers:
  web:
    - YOUR_SERVER_IP  # Update with new server IP

# SSL configuration with Let's Encrypt
proxy:
  ssl: true
  host: feedbackbin.com
  # Add app port if using custom port
  app_port: 3000

# Registry configuration
registry:
  username: murny
  password:
    - KAMAL_REGISTRY_PASSWORD

# Environment variables
env:
  secret:
    - RAILS_MASTER_KEY
    - DATABASE_URL  # If using external DB
  clear:
    SOLID_QUEUE_IN_PUMA: true
    RAILS_LOG_LEVEL: info
    RAILS_SERVE_STATIC_FILES: true
    # Add domain for CORS/security
    APP_DOMAIN: feedbackbin.com

# SSH configuration for deploy user
ssh:
  user: deploy
  port: 2222  # Custom SSH port

# Volumes for persistent storage
volumes:
  - "feedbackbin_storage:/rails/storage"
  - "feedbackbin_db:/rails/db"  # Separate volume for SQLite

# Asset bridging
asset_path: /rails/public/assets

# Builder configuration
builder:
  arch: amd64
  cache:
    type: registry
  args:
    RUBY_VERSION: 3.4.5

# Health check
healthcheck:
  path: /up
  port: 3000
  max_attempts: 10
  interval: 20s

# Aliases for convenience
aliases:
  console: app exec --interactive --reuse "bin/rails console"
  shell: app exec --interactive --reuse "bash"
  logs: app logs -f
  dbc: app exec --interactive --reuse "bin/rails dbconsole"
  backup: app exec "tar -czf /rails/storage/backup-$(date +%Y%m%d-%H%M%S).tar.gz /rails/db/production.sqlite3"
```

### Phase 4: GitHub Actions Setup

Update `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches:
      - main
  workflow_dispatch:  # Allow manual triggers

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version-file: .ruby-version
          bundler-cache: true
      
      - name: Run tests
        run: |
          bin/rails db:test:prepare
          bin/rails test

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    env:
      KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
      RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
    
    steps:
      - name: Checkout code
        uses: actions/checkout@v4
      
      - name: Set up Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version-file: .ruby-version
          bundler-cache: true
      
      - name: Install Kamal
        run: gem install kamal
      
      - name: Setup Docker Buildx
        uses: docker/setup-buildx-action@v3
      
      - name: Configure SSH
        uses: webfactory/ssh-agent@v0.9.0
        with:
          ssh-private-key: ${{ secrets.SSH_PRIVATE_KEY }}
      
      - name: Add server to known hosts
        run: |
          mkdir -p ~/.ssh
          ssh-keyscan -p 2222 -H ${{ secrets.SERVER_IP }} >> ~/.ssh/known_hosts
      
      - name: Deploy with Kamal
        run: |
          kamal deploy
        env:
          KAMAL_REGISTRY_PASSWORD: ${{ secrets.KAMAL_REGISTRY_PASSWORD }}
          RAILS_MASTER_KEY: ${{ secrets.RAILS_MASTER_KEY }}
```

### Phase 5: DNS Configuration

#### 5.1 Update DNS Records
At your domain registrar or DNS provider:

```
Type    Name    Value               TTL
A       @       YOUR_SERVER_IP      300
A       www     YOUR_SERVER_IP      300
```

#### 5.2 SSL Certificate Setup
Kamal proxy handles Let's Encrypt automatically when `ssl: true` is set.

### Phase 6: Backup Strategy

#### 6.1 SQLite Backup Script
Create `/home/deploy/backup.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/home/deploy/backups"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
CONTAINER_NAME="feedbackbin-web"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup SQLite database
docker exec $CONTAINER_NAME tar -czf - /rails/db/production.sqlite3 /rails/storage > $BACKUP_DIR/backup-$TIMESTAMP.tar.gz

# Keep only last 7 days of backups
find $BACKUP_DIR -name "backup-*.tar.gz" -mtime +7 -delete

# Optional: Upload to S3/DigitalOcean Spaces
# aws s3 cp $BACKUP_DIR/backup-$TIMESTAMP.tar.gz s3://your-bucket/backups/
```

#### 6.2 Automated Backups
```bash
# Add to crontab
crontab -e

# Daily backup at 2 AM
0 2 * * * /home/deploy/backup.sh
```

### Phase 7: Monitoring Setup

#### 7.1 Basic Monitoring
```bash
# Install monitoring tools
apt install -y htop netdata

# Netdata will be available at http://YOUR_SERVER_IP:19999
```

#### 7.2 Application Monitoring
Add to your Rails app:

```ruby
# Gemfile
gem 'rails_performance' # Simple Rails monitoring
# or
gem 'skylight' # More comprehensive monitoring
```

### Phase 8: Deployment Execution

#### 8.1 Initial Setup
```bash
# On your local machine
# 1. Set up secrets
export KAMAL_REGISTRY_PASSWORD="your_dockerhub_token"
export RAILS_MASTER_KEY=$(cat config/master.key)

# 2. Setup Kamal
kamal setup

# 3. First deployment
kamal deploy
```

#### 8.2 GitHub Secrets Setup
Add these secrets in GitHub repository settings:

1. `KAMAL_REGISTRY_PASSWORD` - Docker Hub access token
2. `RAILS_MASTER_KEY` - Contents of config/master.key
3. `SSH_PRIVATE_KEY` - Private SSH key for deploy user
4. `SERVER_IP` - Your VPS IP address

### Phase 9: Post-Deployment

#### 9.1 Verify Deployment
```bash
# Check running containers
kamal app details

# View logs
kamal logs

# Access Rails console
kamal console

# Check application health
curl https://feedbackbin.com/up
```

#### 9.2 Performance Tuning
Monitor and adjust:
- Puma workers (`WEB_CONCURRENCY`)
- Job concurrency (`JOB_CONCURRENCY`)
- Docker resources
- Database connection pool

### Phase 10: Maintenance Plan

#### Weekly Tasks
- Review application logs
- Check backup integrity
- Monitor disk usage

#### Monthly Tasks
- Review security updates
- Audit user access
- Performance analysis
- Test backup restoration

#### Quarterly Tasks
- Update dependencies
- Security audit
- Disaster recovery drill

## Best Practices for 2025

### 1. Kamal 2.x Features
- **Proxy with automatic SSL** - Built-in Traefik proxy
- **Zero-downtime deployments** - Automatic health checks
- **Multi-environment support** - Staging/production configs
- **Better secrets management** - Integration with password managers

### 2. SQLite in Production
- **Volume management** - Separate volumes for DB and storage
- **Regular backups** - Automated with verification
- **Litestream** - Consider for real-time replication
- **Performance** - Enable WAL mode, optimize pragmas

### 3. Security
- **SSH hardening** - Non-standard port, key-only auth
- **Firewall** - Minimal open ports
- **Automatic updates** - Security patches only
- **Secrets rotation** - Regular key rotation
- **Monitoring** - Fail2ban, log analysis

### 4. CI/CD
- **Test before deploy** - Run test suite
- **Staged rollout** - Deploy to staging first
- **Rollback plan** - Keep previous versions
- **Health checks** - Verify deployment success

## Troubleshooting

### Common Issues

1. **SSH Connection Issues**
```bash
# Debug SSH connection
ssh -vvv deploy@SERVER_IP -p 2222

# Check SSH service
systemctl status sshd
```

2. **Docker Permission Issues**
```bash
# Ensure deploy user is in docker group
sudo usermod -aG docker deploy
# Logout and login again
```

3. **SSL Certificate Issues**
```bash
# Check Traefik logs
kamal proxy logs

# Verify DNS propagation
dig feedbackbin.com
```

4. **Database Lock Issues**
```bash
# Enable WAL mode for SQLite
kamal app exec "rails runner 'ActiveRecord::Base.connection.execute(\"PRAGMA journal_mode=WAL\")'"
```

## Next Steps

1. **Immediate Actions**
   - [ ] Install Kamal locally
   - [ ] Update server IP in config/deploy.yml
   - [ ] Create new VPS with security hardening
   - [ ] Set up GitHub secrets

2. **Before First Deploy**
   - [ ] Test deployment to staging
   - [ ] Verify backup/restore process
   - [ ] Document emergency procedures
   - [ ] Set up monitoring

3. **After Deployment**
   - [ ] Monitor application performance
   - [ ] Review logs for errors
   - [ ] Test all critical paths
   - [ ] Document any issues/solutions

## Resources

- [Kamal Documentation](https://kamal-deploy.org)
- [Rails 8 Deployment Guide](https://guides.rubyonrails.org/deployment.html)
- [DigitalOcean Security Best Practices](https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu)
- [SQLite in Production](https://litestream.io/guides/rails/)