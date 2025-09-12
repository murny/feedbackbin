# FeedbackBin Deployment Checklist

## Pre-Deployment Setup

### Local Environment
- [ ] Install Kamal: `gem install kamal`
- [ ] Verify Kamal version: `kamal version` (should be 2.x)
- [ ] Create `.env` file from `.env.example`
- [ ] Set `KAMAL_REGISTRY_PASSWORD` (Docker Hub token)
- [ ] Set `RAILS_MASTER_KEY` (from config/master.key)
- [ ] Test Docker build locally: `docker build -t feedbackbin .`

### VPS Provisioning
- [ ] Create DigitalOcean Droplet (Ubuntu 24.04, 2GB RAM minimum)
- [ ] Note the server IP address
- [ ] Add your SSH public key during creation
- [ ] Run setup script: `bash <(curl -s https://raw.githubusercontent.com/yourusername/feedbackbin/main/scripts/setup_vps.sh)`
- [ ] Test SSH connection: `ssh -p 2222 deploy@SERVER_IP`
- [ ] Remove temporary port 22: `sudo ufw delete allow 22/tcp`

### GitHub Repository
- [ ] Add secret: `KAMAL_REGISTRY_PASSWORD`
- [ ] Add secret: `RAILS_MASTER_KEY`
- [ ] Add secret: `SSH_PRIVATE_KEY`
- [ ] Add secret: `SERVER_IP`
- [ ] Add secret: `SSH_USER` (set to "deploy")
- [ ] Add secret: `SSH_PORT` (set to "2222")
- [ ] Add secret: `APP_DOMAIN` (set to "feedbackbin.com")

### DNS Configuration
- [ ] Update A record: `@ -> SERVER_IP`
- [ ] Update A record: `www -> SERVER_IP`
- [ ] Wait for DNS propagation (use `dig feedbackbin.com`)

## Initial Deployment

### First Deploy
- [ ] Update `SERVER_IP` in config/deploy.yml or set env var
- [ ] Run Kamal setup: `kamal setup`
- [ ] Deploy application: `kamal deploy`
- [ ] Check container status: `kamal app details`
- [ ] View logs: `kamal logs`

### Verification
- [ ] Test HTTP: `curl http://SERVER_IP`
- [ ] Test HTTPS: `curl https://feedbackbin.com`
- [ ] Check health endpoint: `curl https://feedbackbin.com/up`
- [ ] Access Rails console: `kamal console`
- [ ] Run database migrations: `kamal migrate`

### SSL Certificate
- [ ] Verify SSL auto-provisioned by Kamal proxy
- [ ] Check certificate: `openssl s_client -connect feedbackbin.com:443 -servername feedbackbin.com`
- [ ] Test SSL Labs: https://www.ssllabs.com/ssltest/analyze.html?d=feedbackbin.com

## Post-Deployment

### Monitoring
- [ ] Access Netdata: `http://SERVER_IP:19999`
- [ ] Set up uptime monitoring (UptimeRobot, Pingdom, etc.)
- [ ] Configure error tracking (Sentry, Honeybadger, etc.)
- [ ] Set up log aggregation (optional)

### Backups
- [ ] Verify backup script: `ssh deploy@SERVER_IP -p 2222 'bash /home/deploy/backup.sh'`
- [ ] Check backup cron job: `ssh deploy@SERVER_IP -p 2222 'crontab -l'`
- [ ] Test backup restoration process
- [ ] Set up offsite backup (S3, DigitalOcean Spaces, etc.)

### Security Audit
- [ ] Check open ports: `ssh deploy@SERVER_IP -p 2222 'sudo netstat -tlnp'`
- [ ] Review fail2ban status: `ssh deploy@SERVER_IP -p 2222 'sudo fail2ban-client status'`
- [ ] Check firewall rules: `ssh deploy@SERVER_IP -p 2222 'sudo ufw status verbose'`
- [ ] Review SSH config: `ssh deploy@SERVER_IP -p 2222 'sudo sshd -T | grep -E "^(permitrootlogin|passwordauthentication|port)"'`

### Performance Testing
- [ ] Run load test (use tools like k6, Apache Bench, etc.)
- [ ] Monitor resource usage during load
- [ ] Adjust Puma workers if needed
- [ ] Optimize database queries

## Continuous Deployment

### GitHub Actions
- [ ] Enable deployment workflow (uncomment in .github/workflows/deploy.yml)
- [ ] Make a test commit to main branch
- [ ] Monitor Actions tab for deployment
- [ ] Verify deployment succeeded
- [ ] Check application after auto-deploy

### Rollback Plan
- [ ] Document rollback procedure
- [ ] Test rollback: `kamal rollback`
- [ ] Keep previous images available
- [ ] Have database backup before major changes

## Maintenance Tasks

### Daily
- [ ] Check application logs for errors
- [ ] Monitor disk usage
- [ ] Review backup completion

### Weekly
- [ ] Review Fail2ban logs
- [ ] Check for security updates
- [ ] Analyze performance metrics
- [ ] Test backup restoration

### Monthly
- [ ] Update dependencies: `bundle update`
- [ ] Review and rotate secrets
- [ ] Audit user access
- [ ] Performance optimization review

### Quarterly
- [ ] Security audit
- [ ] Disaster recovery drill
- [ ] Review and update documentation
- [ ] Capacity planning

## Troubleshooting Commands

```bash
# SSH to server
ssh -p 2222 deploy@SERVER_IP

# View Kamal logs
kamal logs
kamal proxy logs

# Container management
kamal app details
kamal app exec 'bin/rails console'
kamal app exec 'bin/rails db:migrate'

# Restart application
kamal app restart

# Rollback deployment
kamal rollback

# Server diagnostics
ssh deploy@SERVER_IP -p 2222 'df -h'  # Disk usage
ssh deploy@SERVER_IP -p 2222 'free -m'  # Memory usage
ssh deploy@SERVER_IP -p 2222 'docker ps'  # Running containers
ssh deploy@SERVER_IP -p 2222 'docker system df'  # Docker disk usage

# Clean up Docker
kamal app exec 'docker system prune -af'

# View fail2ban status
ssh deploy@SERVER_IP -p 2222 'sudo fail2ban-client status sshd'

# Unban IP address
ssh deploy@SERVER_IP -p 2222 'sudo fail2ban-client unban IP_ADDRESS'
```

## Emergency Contacts

- **DigitalOcean Support**: https://www.digitalocean.com/support/
- **Docker Hub Status**: https://www.dockerstatus.com/
- **GitHub Status**: https://www.githubstatus.com/
- **Domain Registrar**: [Your registrar support]

## Notes

- Keep this checklist updated with any changes
- Document any issues and resolutions
- Share with team members who need deployment access
- Review and update quarterly