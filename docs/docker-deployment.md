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

#### BASE_URL

The public URL of your instance, used for links in emails (magic links,
invitations, notifications). Without it, emails can't be sent.

```sh
docker run --env BASE_URL=https://feedback.example.com ...
```

### SSL

FeedbackBin requires HTTPS in production: cookies are marked secure and HTTP
requests are redirected. Choose one of:

- **Automatic certificates.** Set `TLS_DOMAIN` to your domain and publish ports
  80 and 443. [Thruster](https://github.com/basecamp/thruster) provisions a
  Let's Encrypt certificate on first request. The domain's DNS must already
  point at the server.

  ```sh
  docker run --publish 80:80 --publish 443:443 --env TLS_DOMAIN=feedback.example.com ...
  ```

- **Your own reverse proxy.** Terminate SSL at your proxy or load balancer
  (Caddy, nginx, Cloudflare, etc.) and forward plain HTTP to port 80 of the
  container. Leave `TLS_DOMAIN` unset.

### SMTP Email

FeedbackBin sends email for sign-in (magic links), invitations, and
notifications. Any SMTP provider works (Postmark, SendGrid, Mailgun, SES, etc.).

| Variable | Description | Default |
|----------|-------------|---------|
| `SMTP_ADDRESS` | SMTP server address. Enables SMTP delivery. | - |
| `SMTP_PORT` | SMTP port | 587 (465 with `SMTP_TLS`) |
| `SMTP_USERNAME` | SMTP username | - |
| `SMTP_PASSWORD` | SMTP password | - |
| `SMTP_DOMAIN` | Domain for the HELO command | - |
| `SMTP_AUTHENTICATION` | `plain`, `login`, or `cram_md5` | `plain` |
| `SMTP_TLS` | Set to `true` for implicit TLS (port 465). STARTTLS is used automatically otherwise. | `false` |
| `SMTP_SSL_VERIFY_MODE` | Set to `none` to skip certificate verification | - |
| `MAILER_FROM_ADDRESS` | Sender for all emails, e.g. `Feedback <feedback@example.com>` | `FeedbackBin <support@feedbackbin.com>` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MULTI_TENANT` | Set to `true` to allow anyone to sign up and create a new account. Otherwise only the first account can be created. | `false` |
| `SOLID_QUEUE_IN_PUMA` | Run background jobs inside the web process. Set to `false` if you run `bin/jobs` separately. | `true` |
| `JOB_CONCURRENCY` | Number of background job processes | 1 |
| `WEB_CONCURRENCY` | Number of Puma worker processes | 1 |
| `RAILS_MAX_THREADS` | Threads per Puma worker | 3 |
| `RAILS_LOG_LEVEL` | Log level | `info` |

### Sign in with Google or Facebook

Magic-link email sign-in works out of the box. Google and Facebook sign-in read
their keys from Rails encrypted credentials, which the pre-built image can't
include. To enable them, build your own image or deploy with
[Kamal](kamal-deployment.md) and add `google_app_id`, `google_app_secret`,
`facebook_app_id`, and `facebook_app_secret` with `bin/rails credentials:edit`.

## Quick Start

### Using Docker Run

```sh
docker run \
  --publish 80:80 \
  --publish 443:443 \
  --restart unless-stopped \
  --volume feedbackbin-storage:/rails/storage \
  --env SECRET_KEY_BASE=your_secret_key_here \
  --env BASE_URL=https://feedback.example.com \
  --env TLS_DOMAIN=feedback.example.com \
  --env SMTP_ADDRESS=smtp.example.com \
  --env SMTP_USERNAME=your_smtp_username \
  --env SMTP_PASSWORD=your_smtp_password \
  --env MAILER_FROM_ADDRESS="Feedback <feedback@example.com>" \
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
      - "443:443"
    volumes:
      - feedbackbin-storage:/rails/storage
    environment:
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      BASE_URL: https://feedback.example.com
      TLS_DOMAIN: feedback.example.com
      SMTP_ADDRESS: smtp.example.com
      SMTP_USERNAME: ${SMTP_USERNAME}
      SMTP_PASSWORD: ${SMTP_PASSWORD}
      MAILER_FROM_ADDRESS: "Feedback <feedback@example.com>"

volumes:
  feedbackbin-storage:
```

Create a `.env` file with your secrets:

```sh
SECRET_KEY_BASE=your_secret_key_here
SMTP_USERNAME=your_smtp_username
SMTP_PASSWORD=your_smtp_password
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
- Missing `BASE_URL` (sign-in emails fail to send)
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
