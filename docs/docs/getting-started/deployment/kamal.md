---
layout: docs
title: Kamal Deployment
description: "Deploy FeedbackBin with zero-downtime using Kamal for production-ready, automated deployments."
---

Deploy FeedbackBin using [Kamal](https://kamal-deploy.org/) - the recommended deployment method that provides zero-downtime deployments with automatic SSL certificates.

## Prerequisites

- A Linux server (Ubuntu 20.04+ recommended)
- A domain name pointing to your server
- Docker Hub account
- Kamal CLI installed locally: `gem install kamal`

## Setup

### 1. Clone and Configure

```bash
git clone https://github.com/{{ site.github_repository }}.git
cd feedbackbin
```

### 2. Add Secrets

Create `.kamal/secrets` with your credentials:

```bash
# Docker Hub credentials
KAMAL_REGISTRY_PASSWORD=your-docker-hub-password

# Rails master key (generate with: rails secret)
RAILS_MASTER_KEY=your-64-character-secret-key
```

### 3. Update Deploy Configuration

Edit `config/deploy.yml`:

```yaml
service: feedbackbin
image: your-username/feedbackbin

servers:
  web:
    - your-server-ip-address

proxy:
  ssl: true
  host: your-domain.com

registry:
  username: your-docker-username
  password:
    - KAMAL_REGISTRY_PASSWORD

env:
  secret:
    - RAILS_MASTER_KEY
  clear:
    SELF_HOSTED: true
    RAILS_ENV: production

volumes:
  - "feedbackbin_storage:/rails/storage"
```

### 4. Deploy

```bash
kamal setup
```

## Updates

For future deployments:

```bash
kamal deploy
```

## Essential Commands

```bash
# View logs
kamal app logs -f

# Access Rails console
kamal app exec 'bin/rails console'

# Rollback if needed
kamal rollback

# Check status
kamal details
```

## Post-Deployment

Create your first admin user:

```bash
kamal app exec 'bin/rails console'
```

```ruby
user = User.create!(
  name: "Admin",
  email: "admin@yourcompany.com",
  password: "secure-password",
  confirmed_at: Time.current
)

org = Organization.create!(name: "Your Company")
Membership.create!(user: user, organization: org, role: "admin")
```

Then visit `https://your-domain.com` to start using FeedbackBin.