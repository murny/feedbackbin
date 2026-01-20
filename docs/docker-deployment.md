---
layout: page
title: Docker Deployment Guide
permalink: /docs/docker-deployment/
description: "Deploy FeedbackBin using Docker. Complete guide for running FeedbackBin in containers."
---

# Deploying with Docker

We provide pre-built Docker images that can be used to run FeedbackBin on your
own server.

If you don't need to change the source code and just want the out-of-the-box
FeedbackBin experience, this is the easiest way to get started.

You'll find the latest version of FeedbackBin's Docker image at
`ghcr.io/murny/feedbackbin:master`.

To run it you'll need:
- A machine that runs Docker
- A mounted volume (so that your database persists between restarts)
- Some environment variables for configuration

## Mounting a Storage Volume

FeedbackBin keeps all of its storage inside `/rails/storage`. This includes:
- SQLite databases (`/rails/storage/db/`)
- File uploads (`/rails/storage/files/`)

By default, Docker containers don't persist storage between runs, so you'll
want to mount a persistent volume into that location.

### Using Named Volumes (Recommended)

The simplest way is with a named volume:

```sh
docker run --volume feedbackbin-storage:/rails/storage ghcr.io/murny/feedbackbin:master
```

Docker handles permissions automatically with named volumes.

### Using Bind Mounts

If you prefer to specify the data location yourself:

```sh
# First, set correct ownership on the host (UID 1000)
sudo chown -R 1000:1000 /path/to/host/storage

# Then mount it
docker run --volume /path/to/host/storage:/rails/storage ghcr.io/murny/feedbackbin:master
```

**Important:** The FeedbackBin container runs as a non-root user (`rails`, UID
1000) for security. Host-mounted volumes must be owned by UID 1000.

## Environment Variables

### Required Variables

#### SECRET_KEY_BASE

Various features inside FeedbackBin rely on cryptography (such as secure
sessions). You need to provide a secret value that will be used as the basis
for these secrets.

Generate a secret key:

```sh
docker run --rm ghcr.io/murny/feedbackbin:master bin/rails secret
```

Then set it:

```sh
docker run --env SECRET_KEY_BASE=your_generated_secret ...
```

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `RAILS_MASTER_KEY` | Rails credentials encryption key | - |
| `HTTP_PORT` | HTTP port to listen on | 80 |

### SSL Configuration

FeedbackBin uses [Thruster](https://github.com/basecamp/thruster) for SSL
termination. If you're running behind a reverse proxy that handles SSL, you can
disable it:

```sh
docker run --publish 80:80 ...
```

If you want the container to handle SSL directly, configure your reverse proxy
or load balancer to terminate SSL and forward to the container.

### SMTP Email

FeedbackBin needs to send email for authentication (magic links) and
notifications. Configure your SMTP settings:

| Variable | Description |
|----------|-------------|
| `SMTP_ADDRESS` | SMTP server address |
| `SMTP_PORT` | SMTP port (default: 587) |
| `SMTP_USERNAME` | SMTP username |
| `SMTP_PASSWORD` | SMTP password |
| `SMTP_DOMAIN` | Domain for HELO command |

You can use any SMTP provider (Postmark, SendGrid, Mailgun, etc.).

## Quick Start

### Using Docker Run

```sh
docker run \
  --publish 80:80 \
  --restart unless-stopped \
  --volume feedbackbin-storage:/rails/storage \
  --env SECRET_KEY_BASE=your_secret_key_here \
  --name feedbackbin \
  ghcr.io/murny/feedbackbin:master
```

### Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
services:
  feedbackbin:
    image: ghcr.io/murny/feedbackbin:master
    container_name: feedbackbin
    restart: unless-stopped
    ports:
      - "80:80"
    volumes:
      - feedbackbin-storage:/rails/storage
    environment:
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      # Add SMTP settings for email
      # SMTP_ADDRESS: mail.example.com
      # SMTP_USERNAME: user
      # SMTP_PASSWORD: pass

volumes:
  feedbackbin-storage:
```

Create a `.env` file with your secrets:

```sh
SECRET_KEY_BASE=your_secret_key_here
```

Start the application:

```sh
docker compose up -d
```

Check logs:

```sh
docker compose logs -f feedbackbin
```

## Building from Source

If you want to build the Docker image yourself:

```sh
# Clone the repository
git clone https://github.com/murny/feedbackbin.git
cd feedbackbin

# Build the image
docker build -t feedbackbin .

# Run your custom build
docker run \
  --publish 80:80 \
  --volume feedbackbin-storage:/rails/storage \
  --env SECRET_KEY_BASE=your_secret_key_here \
  feedbackbin
```

## Troubleshooting

### Permission Errors

If you see permission errors, ensure your volume is owned by UID 1000:

```sh
sudo chown -R 1000:1000 /path/to/your/storage
```

### Container Won't Start

Check the logs:

```sh
docker logs feedbackbin
```

Common issues:
- Missing `SECRET_KEY_BASE`
- Volume permission problems
- Port already in use

### Database Issues

The SQLite database is stored in `/rails/storage/db/`. If you need to reset:

```sh
docker exec feedbackbin bin/rails db:reset
```

## Next Steps

- For more control over deployments, see the [Kamal Deployment Guide](kamal-deployment.md)
- For development setup, see the [Development Guide](development.md)
