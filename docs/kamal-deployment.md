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
2. Clone your fork and run `bin/setup`
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
bin/setup
```

## Configuration

### Deploy Configuration

`config/deploy.yml` is set up for feedbackbin.com. Change these settings for
your instance:

```yaml
image: ghcr.io/your-github-username/feedbackbin

servers:
  web:
    - your-server-ip  # SSH-accessible hostname or IP (Kamal connects as root by default)

proxy:
  ssl: true
  host: feedback.example.com  # Your domain

registry:
  server: ghcr.io
  username: your-github-username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - RAILS_MASTER_KEY
  clear:
    SOLID_QUEUE_IN_PUMA: true
    BASE_URL: https://feedback.example.com
    SMTP_ADDRESS: smtp.example.com
    SMTP_DOMAIN: example.com
```

See the [Docker Deployment Guide](docker-deployment.md#environment-variables)
for every supported environment variable.

### Credentials

The repository's `config/credentials.yml.enc` belongs to feedbackbin.com and
can't be decrypted without its key. Replace it with your own:

```sh
rm config/credentials.yml.enc
bin/rails credentials:edit
```

This creates `config/master.key` (git-ignored) and a new encrypted credentials
file containing a `secret_key_base`. Add your SMTP login and, optionally, OAuth
keys:

```yaml
smtp:
  user_name: your_smtp_username
  password: your_smtp_password

google_app_id: ...
google_app_secret: ...
facebook_app_id: ...
facebook_app_secret: ...
```

`SMTP_USERNAME` and `SMTP_PASSWORD` environment variables take precedence over
the `smtp` credentials if you'd rather pass them as Kamal secrets.

### Secrets

`.kamal/secrets` is committed to git and holds no secret values itself. It
reads them from your environment and `config/master.key` at deploy time:

```sh
KAMAL_REGISTRY_PASSWORD=$KAMAL_REGISTRY_PASSWORD
RAILS_MASTER_KEY=$(cat config/master.key)
```

Export a GitHub personal access token with `write:packages` scope before
deploying:

```sh
export KAMAL_REGISTRY_PASSWORD=ghp_your_token
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

Set `SMTP_ADDRESS` (and optionally `SMTP_PORT`, `SMTP_DOMAIN`) under
`env.clear`, and the login in credentials as shown above.

### File Storage

Uploaded files (avatars, logos) and the SQLite databases live in the
`feedbackbin_storage` Docker volume mounted at `/rails/storage`. Back this
volume up regularly.

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
- `KAMAL_REGISTRY_PASSWORD` not exported, or `config/master.key` missing
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
