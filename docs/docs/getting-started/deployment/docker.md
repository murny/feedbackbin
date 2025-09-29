---
layout: docs
title: Docker Deployment
description: "Deploy FeedbackBin using Docker containers with full control over your infrastructure and configuration."
---

Deploy FeedbackBin using Docker containers for maximum flexibility and integration with existing infrastructure.

## Prerequisites

- Docker and Docker Compose installed
- A server with ports 3000 open (or configure reverse proxy)

## Setup with Docker Compose

### 1. Create Docker Compose File

Create `docker-compose.yml`:

```yaml
version: '3.8'
services:
  feedbackbin:
    build: https://github.com/{{ site.github_repository }}.git
    ports:
      - "3000:3000"
    environment:
      - RAILS_ENV=production
      - SELF_HOSTED=true
      - RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
    volumes:
      - feedbackbin_storage:/rails/storage
    restart: unless-stopped

volumes:
  feedbackbin_storage:
```

### 2. Set Environment Variables

```bash
export RAILS_MASTER_KEY=your-64-character-secret-key
```

### 3. Deploy

```bash
docker-compose up -d
```

Access FeedbackBin at `http://your-server:3000`.

## Management Commands

```bash
# View logs
docker-compose logs -f

# Access Rails console
docker-compose exec feedbackbin bin/rails console

# Update to latest version
docker-compose pull && docker-compose up -d

# Stop services
docker-compose down
```

## Create Admin User

```bash
docker-compose exec feedbackbin bin/rails console
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

## Adding a Reverse Proxy

For production use with SSL, add a reverse proxy like Nginx:

```yaml
version: '3.8'
services:
  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/ssl
    depends_on:
      - feedbackbin

  feedbackbin:
    build: https://github.com/{{ site.github_repository }}.git
    environment:
      - RAILS_ENV=production
      - SELF_HOSTED=true
      - RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
    volumes:
      - feedbackbin_storage:/rails/storage

volumes:
  feedbackbin_storage:
```

Configure Nginx to proxy requests to the FeedbackBin container on port 3000.