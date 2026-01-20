---
layout: page
title: Kamal Deployment Guide
permalink: /docs/kamal-deployment/
description: "Deploy FeedbackBin with Kamal for zero-downtime deployments and full control over your infrastructure."
---

# Deploying with Kamal

If you'd like to run FeedbackBin on your own server while having the freedom to
easily make changes to its code, we recommend deploying with
[Kamal](https://kamal-deploy.org/).

Kamal makes it easy to set up a bare server, copy the application to it, and
manage configuration. It handles zero-downtime deployments with automatic
rollbacks.

## Prerequisites

- A VPS or dedicated server (DigitalOcean, Hetzner, AWS, etc.)
- SSH access to your server
- A domain name pointed to your server
- Docker installed on your local machine

## Getting Started

The steps to deploy your own FeedbackBin instance:

1. Fork the repository
2. Clone your fork and run `bin/setup --skip-server`
3. Configure `config/deploy.yml` and `.kamal/secrets`
4. Run `kamal setup` for your first deploy

## Fork and Clone

Start by creating your own GitHub fork of the repository. This allows you to
commit your configuration changes and track them over time.

```sh
# Clone your fork
git clone https://github.com/yourusername/feedbackbin.git
cd feedbackbin

# Set up the development environment
bin/setup --skip-server
```

## Configuration

### Deploy Configuration

Edit `config/deploy.yml` with your server details. The key settings are:

```yaml
servers:
  web:
    - your-server-hostname  # SSH-accessible hostname or IP

ssh:
  user: root  # Or your SSH user

proxy:
  ssl: true
  host: feedbackbin.example.com  # Your domain

env:
  clear:
    # Public environment variables
    RAILS_ENV: production
```

### Secrets

Create a `.kamal/secrets` file for sensitive configuration. **Do not commit
this file to git!**

```sh
# Add to .gitignore if not already there
echo ".kamal/secrets" >> .gitignore
```

Create the secrets file:

```ini
SECRET_KEY_BASE=your_secret_key_here
RAILS_MASTER_KEY=your_master_key_here
SMTP_USERNAME=your_smtp_username
SMTP_PASSWORD=your_smtp_password
```

Generate values:

```sh
# Generate SECRET_KEY_BASE
bin/rails secret

# RAILS_MASTER_KEY is in config/master.key (create if missing)
bin/rails credentials:edit
```

### Using a Password Manager

If you use 1Password or another password manager, you can store secrets there
instead. See the [Kamal documentation](https://kamal-deploy.org/docs/configuration/environment-variables/#secrets)
for details.

## First Deployment

Once configured, deploy FeedbackBin:

```sh
# First-time setup (installs Docker, configures server, deploys app)
bin/kamal setup
```

This will:
- Install Docker on your server (if needed)
- Build the FeedbackBin Docker image
- Push the image to the registry
- Start the application with SSL

## Subsequent Deployments

After the initial setup, deploy changes with:

```sh
bin/kamal deploy
```

## Common Configuration

### SSL Certificates

Kamal uses Let's Encrypt for automatic SSL certificates. Ensure your domain's
DNS is configured before deploying.

If you're terminating SSL elsewhere (load balancer, Cloudflare), disable it:

```yaml
proxy:
  ssl: false
```

### SMTP Email

Configure email for authentication and notifications:

```yaml
env:
  clear:
    SMTP_ADDRESS: smtp.example.com
    SMTP_PORT: 587
  secret:
    - SMTP_USERNAME
    - SMTP_PASSWORD
```

### File Storage

By default, uploaded files are stored on the server. For S3 or compatible
storage:

```yaml
env:
  clear:
    ACTIVE_STORAGE_SERVICE: s3
    S3_BUCKET: your-bucket-name
    S3_REGION: us-east-1
  secret:
    - S3_ACCESS_KEY_ID
    - S3_SECRET_ACCESS_KEY
```

For S3-compatible services (Cloudflare R2, MinIO, etc.):

```yaml
env:
  clear:
    S3_ENDPOINT: https://your-endpoint.com
    S3_FORCE_PATH_STYLE: true
```

## Useful Commands

```sh
# View application logs
bin/kamal app logs

# Open a Rails console on the server
bin/kamal app exec --interactive bin/rails console

# Run database migrations
bin/kamal app exec bin/rails db:migrate

# Restart the application
bin/kamal app restart

# View deployment status
bin/kamal details
```

## Server Requirements

- **OS:** Ubuntu 20.04+ or similar Linux distribution
- **RAM:** 1GB minimum (2GB+ recommended)
- **Storage:** 20GB+ SSD recommended
- **Ports:** 22 (SSH), 80 (HTTP), 443 (HTTPS)

## Troubleshooting

### Deployment Fails

Check the logs:

```sh
bin/kamal app logs
```

Common issues:
- Missing secrets in `.kamal/secrets`
- SSH connection problems
- Docker build failures

### SSL Certificate Issues

Ensure your domain points to your server before deploying. Let's Encrypt needs
to verify domain ownership.

### Database Migration Errors

Run migrations manually:

```sh
bin/kamal app exec bin/rails db:migrate
```

## Next Steps

- For simpler deployments, see the [Docker Deployment Guide](docker-deployment.md)
- For development setup, see the [Development Guide](development.md)
- Read the [Kamal documentation](https://kamal-deploy.org/) for advanced configuration
