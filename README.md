<div align="center">

<img src="public/icon.svg" alt="FeedbackBin Logo" width="120" height="120" />

# FeedbackBin

**A modern, self-hosted customer feedback management platform**

> **⚠️ MVP Development Notice**
> 
> FeedbackBin is currently in active development towards its minimal viable product (MVP). 
> While functional, the software is not yet production-ready. We're working hard to deliver 
> a stable release soon. Stay tuned for updates!

[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)
[![Ruby](https://img.shields.io/badge/Ruby-3.4.x-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.x-red.svg)](https://rubyonrails.org/)

[Features](#-features) • [Quick Start](#-quick-start) • [Documentation](#-documentation) • [Contributing](#-contributing) • [License](#-license)

</div>

---

## 🚀 Introduction

FeedbackBin is a powerful, self-hosted customer feedback management platform built with Ruby on Rails 8. It provides organizations with a comprehensive solution to collect, organize, and act on customer feedback through an intuitive, modern interface.

### Why FeedbackBin?

- **Self-hosted**: Complete control over your data and infrastructure
- **Modern Architecture**: Built with Rails 8, Hotwire, and Tailwind CSS
- **Real-time Updates**: Live feedback updates using Turbo Streams
- **Multi-tenant**: Support for multiple organizations with role-based access
- **Privacy-focused**: Your feedback data stays on your servers

## 📋 Table of Contents

- [Features](#-features)
- [Technology Stack](#-technology-stack)
- [Requirements](#-requirements)
- [Quick Start](#-quick-start)
- [Installation](#-installation)
- [Configuration](#%EF%B8%8F-configuration)
- [Development](#-development)
- [Testing](#-testing)
- [Code Quality](#-code-quality)
- [Security](#-security)
- [Deployment](#-deployment)
- [Contributing](#-contributing)
- [Community](#-community)
- [License](#-license)

## ✨ Features

### Core Functionality
- **Feedback Management**: Create, organize, and track customer feedback posts
- **Threaded Comments**: Rich discussion system with nested comments
- **Category Organization**: Logical grouping of feedback items
- **Status Tracking**: Monitor feedback lifecycle with custom statuses
- **User Management**: Role-based access control and user profiles

### Technical Features
- **Real-time Updates**: Live updates using Turbo Streams over WebSocket
- **Rich Text Support**: ActionText integration for formatted content
- **File Uploads**: ActiveStorage support for avatars and attachments
- **OAuth Integration**: Google and Facebook authentication
- **Mobile Responsive**: Mobile-first design with dark/light theme support
- **Background Jobs**: Solid Queue for async processing

### Enterprise Ready
- **Multi-tenancy**: Organization-scoped data access
- **Security**: Comprehensive authorization with Pundit policies
- **Scalable**: SQLite-based architecture optimized for performance
- **Self-hosted**: Complete data ownership and privacy control

## 🛠 Technology Stack

### Backend
- **Ruby 3.4.x** - Modern Ruby with performance improvements
- **Ruby on Rails 8.x** - Latest Rails with new features
- **SQLite3** - Lightweight, serverless database
- **Solid Queue** - Background job processing
- **Solid Cache** - Application caching
- **Solid Cable** - WebSocket connections

### Frontend
- **Hotwire/Turbo** - SPA-like experience without JavaScript complexity
- **Stimulus.js** - Minimal JavaScript controllers
- **Tailwind CSS** - Utility-first CSS framework
- **Import Maps** - Modern JavaScript without bundling
- **Lucide Icons** - Beautiful, customizable icons

### Authentication & Authorization
- **Custom Authentication** - Built with `has_secure_password`
- **OAuth Support** - Google and Facebook integration via Omniauth
- **Pundit** - Policy-based authorization system

### Development & Deployment
- **Kamal** - Container-based deployment
- **Docker** - Containerized application
- **Foreman** - Process management for development

## 📋 Requirements

- **Ruby**: 3.4.x or higher
- **Node.js**: 18.x or higher (for asset pipeline)
- **SQLite**: 3.x (included with most systems)
- **Git**: For version control

## 🚀 Quick Start

Get FeedbackBin running locally in just a few commands:

```bash
# Clone the repository
git clone https://github.com/murny/feedbackbin.git
cd feedbackbin

# Setup and start the application (includes dependency installation)
bin/setup

# The application will be available at http://localhost:3000
```

That's it! The `bin/setup` script handles dependency installation and starts the development server automatically.

## 💾 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/murny/feedbackbin.git
cd feedbackbin
```

### 2. Install Dependencies
```bash
# Install Ruby dependencies
bundle install

# Setup the database and seed data
bin/rails db:setup
```

### 3. Start the Application
```bash
# Start with auto-reload (recommended for development)
bin/dev

# Or start Rails server directly
bin/rails server
```

### 4. Start Background Jobs (Optional)
```bash
# In a separate terminal for background job processing
bin/jobs
```

## ⚙️ Configuration

### Multi-Tenant Mode

FeedbackBin supports both single-tenant and multi-tenant deployments:

**Single-Tenant Mode (Default)**
- One organization per instance
- Subdomains are optional
- Simpler setup for dedicated installations

**Multi-Tenant Mode**
- Multiple organizations with unique subdomains
- Subdomain-based routing
- Enable by setting environment variable:

```bash
# Enable multi-tenant mode
MULTI_TENANT=true
```

In multi-tenant mode, each organization must have a unique subdomain. In single-tenant mode (default), subdomains are optional.

### Credentials
Use Rails encrypted credentials for sensitive configuration:

```bash
# Edit credentials
bin/rails credentials:edit

# Example credentials structure:
# oauth:
#   google:
#     client_id: your_google_client_id
#     client_secret: your_google_client_secret
#   facebook:
#     app_id: your_facebook_app_id
#     app_secret: your_facebook_app_secret
```

## 👩‍💻 Development

### Development Commands
```bash
# Setup project (run once)
bin/setup --skip-server  # Setup without starting server

# Development server with auto-reload
bin/dev                   # Starts server on port 3000

# Background job worker
bin/jobs                  # Process background jobs

# Run full CI pipeline locally
bin/ci                    # Lint, security checks, and tests
```

### Database Operations
```bash
# Create and migrate database
bin/rails db:create db:migrate

# Seed with sample data
bin/rails db:seed

# Reset database (development only)
bin/rails db:reset

# Test database setup
env RAILS_ENV=test bin/rails db:seed:replant
```

## 🧪 Testing

FeedbackBin uses Rails' built-in testing framework with comprehensive coverage:

```bash
# Run all tests
bin/rails test

# Run specific test types
bin/rails test:models     # Model tests
bin/rails test:controllers # Controller tests
bin/rails test:system     # End-to-end browser tests

# Run tests with coverage
COVERAGE=true bin/rails test
```

### Test Structure
- **Unit Tests**: `test/models/` - Model and business logic tests
- **Integration Tests**: `test/controllers/` - Controller and request tests
- **System Tests**: `test/system/` - Full browser automation tests
- **Fixtures**: `test/fixtures/` - Test data setup

## 🔍 Code Quality

### Linting and Formatting

#### Ruby Code
```bash
# Check Ruby code style
bin/rubocop

# Auto-fix Ruby style issues
bin/rubocop -a

# Check specific files
bin/rubocop app/models/user.rb
```

#### ERB Templates
```bash
# Check ERB templates
bin/erb_lint --lint-all

# Auto-fix ERB issues (use with caution)
bin/erb_lint --lint-all -a
```

#### Internationalization
```bash
# Check I18n file health
bin/i18n-tasks health

# Normalize I18n files
bin/i18n-tasks normalize
```

### Code Quality Tools
- **RuboCop**: Ruby style guide enforcement
- **ERB Lint**: ERB template linting
- **I18n Tasks**: Translation file management
- **SimpleCov**: Test coverage reporting

## 🔒 Security

FeedbackBin takes security seriously with multiple layers of protection:

### Security Audits
```bash
# Static security analysis
bin/brakeman

# Check for vulnerable gems
bin/bundler-audit

# JavaScript vulnerability check
bin/importmap audit
```

### Security Features
- **CSRF Protection**: Built-in Rails CSRF protection
- **SQL Injection Prevention**: ActiveRecord parameterized queries
- **XSS Protection**: Automatic HTML escaping
- **Authentication**: Secure password hashing with bcrypt
- **Authorization**: Pundit policy-based access control
- **Session Security**: Secure session management

### Best Practices
- Regular security audits with automated tools
- Dependency vulnerability monitoring
- Secure configuration management with Rails credentials
- Input validation and sanitization
- Regular security updates

## 🚀 Deployment

FeedbackBin supports multiple deployment methods depending on your needs:

### Server Requirements
- **VPS**: Any cloud provider (DigitalOcean, Hetzner, AWS, etc.)
- **OS**: Ubuntu 20.04+ or similar Linux distribution
- **RAM**: 1GB minimum (2GB+ recommended)
- **Storage**: 20GB+ SSD recommended
- **Bandwidth**: Standard web hosting bandwidth

### Server Setup
```bash
# Basic server hardening
# 1. Add SSH key authentication
# 2. Disable password authentication
# 3. Configure firewall (ports 22, 80, 443)
# 4. Update system packages
sudo apt update && sudo apt upgrade -y
```

### Deploying with Docker

FeedbackBin's Docker image contains everything needed for a fully-functional, single-machine deployment. This includes the web app, background jobs, caching, file serving, and SSL support via Thruster.

#### Building and Running

```bash
# Build the image
docker build -t feedbackbin .

# Run the container
docker run \
  --publish 80:80 \
  --restart unless-stopped \
  --volume feedbackbin-storage:/rails/storage \
  --env SECRET_KEY_BASE=$YOUR_SECRET_KEY_BASE \
  --name feedbackbin \
  feedbackbin
```

#### Using the prebuilt image from GHCR.io

If you prefer not to build locally, you can use the published image:

```bash
# Pull the image
docker pull ghcr.io/murny/feedbackbin:master

# Run the container
docker run \
  --publish 80:80 \
  --restart unless-stopped \
  --volume feedbackbin-storage:/rails/storage \
  --env SECRET_KEY_BASE=$YOUR_SECRET_KEY_BASE \
  --name feedbackbin \
  ghcr.io/murny/feedbackbin:master
```

Need a `SECRET_KEY_BASE`? Generate one with:

```bash
docker run --rm ghcr.io/murny/feedbackbin:master bin/rails secret
```

#### Volume Persistence

To persist the database and file attachments, you **must** map a volume to `/rails/storage`. This directory contains:
- SQLite databases (`/rails/storage/db/`)
- File uploads (`/rails/storage/files/`)

#### ⚠️ Important: Volume Permissions

The FeedbackBin container runs as a non-root user (`rails`, UID 1000) for security. **You must ensure that host-mounted volumes are owned by UID 1000** or the container will fail with permission errors.

**For named volumes** (recommended):
```bash
docker run --volume feedbackbin-storage:/rails/storage ...
```
Docker handles permissions automatically. ✅

**For bind mounts** (host directories):
```bash
# First, set correct ownership on the host
sudo chown -R 1000:1000 /path/to/host/storage

# Then mount it
docker run --volume /path/to/host/storage:/rails/storage ...
```

#### Environment Variables

Configure additional features by setting environment variables:

| Variable | Description |
|----------|-------------|
| `SECRET_KEY_BASE` | **Required**. Rails secret for session encryption |
| `RAILS_MASTER_KEY` | Rails credentials encryption key (if using credentials) |
| `HTTP_PORT` | HTTP port to listen on (default: 80) |


### Deploying with Docker Compose

For easier management, use Docker Compose:

#### 1. Create `docker-compose.yml`

```yaml
services:
  feedbackbin:
    image: ghcr.io/murny/feedbackbin:master
    container_name: feedbackbin
    restart: unless-stopped
    ports:
      - "4080:4080"
    volumes:
      # Using bind mount - ensure proper permissions!
      - ./data:/rails/storage
    environment:
      SECRET_KEY_BASE: ${SECRET_KEY_BASE}
      HTTP_PORT: 4080
```

#### 2. Set up environment variables

Create a `.env` file:
```bash
SECRET_KEY_BASE=your_secret_key_base_here
```

Generate a secret key:
```bash
docker run --rm feedbackbin bin/rails secret
```

#### 3. Prepare storage directory

```bash
# Create and set permissions BEFORE starting
mkdir -p ./data
sudo chown -R 1000:1000 ./data
```

#### 4. Start the application

```bash
docker compose up -d
```

#### 5. Check logs

```bash
docker compose logs -f feedbackbin
```

### Deploying with Kamal

For production deployments with zero-downtime updates:

```bash
# Configure deployment settings
cp config/deploy.example.yml config/deploy.yml
# Edit config/deploy.yml with your server details

# Set required environment variables
export KAMAL_REGISTRY_PASSWORD=your_registry_password
export RAILS_MASTER_KEY=your_master_key

# Deploy application
kamal setup      # First-time deployment
kamal deploy     # Subsequent deployments
```

### DNS Configuration
1. Create an A record pointing to your server's IP
2. Optionally create a CNAME for www subdomain
3. Configure SSL certificates (handled automatically by Kamal)

## 🤝 Contributing

We welcome contributions from the community! Here's how to get started:

### Quick Contribution Guide
1. **Fork** the repository
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Make** your changes following our coding standards
4. **Test** your changes (`bin/ci`)
5. **Commit** your changes (`git commit -m 'Add amazing feature'`)
6. **Push** to your branch (`git push origin feature/amazing-feature`)
7. **Open** a Pull Request

### Development Setup for Contributors
```bash
# Fork and clone your fork
git clone https://github.com/yourusername/feedbackbin.git
cd feedbackbin

# Add upstream remote
git remote add upstream https://github.com/murny/feedbackbin.git

# Setup development environment
bin/setup

# Run full test suite
bin/ci
```

### Contribution Guidelines
- Follow Ruby and Rails conventions
- Write comprehensive tests for new features
- Update documentation for user-facing changes
- Use clear, descriptive commit messages
- Ensure all CI checks pass before submitting PR

### Areas We Need Help
- 📖 Documentation improvements
- 🐛 Bug fixes and testing
- 🌐 Internationalization (i18n)
- 🎨 UI/UX enhancements
- 🔒 Security audits and improvements
- 📱 Mobile responsiveness
- ⚡ Performance optimizations

For major changes, please open an issue first to discuss your proposal.

## 🌟 Community

### Get Involved
- **GitHub Discussions**: Ask questions and share ideas
- **Issues**: Report bugs and request features
- **Discord**: *Coming soon* - Join our community chat

### Code of Conduct
We are committed to providing a welcoming and inclusive experience for everyone. Please read our Code of Conduct before participating.

### Support
- 📖 **Documentation**: Comprehensive guides and API reference
- 🐛 **Issue Tracker**: Bug reports and feature requests
- 💬 **Community**: Discussion forums and chat

## 📜 License

FeedbackBin is open-source software licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.

This means you can:
- ✅ Use the software for any purpose
- ✅ Study and modify the source code
- ✅ Distribute copies of the software
- ✅ Distribute modified versions

**Important**: If you run FeedbackBin as a web service, you must make the source code (including any modifications) available to your users under the same license.

Inspired by [Plausible's approach to open source licensing](https://plausible.io/blog/open-source-licenses), this license ensures that FeedbackBin remains free and open for everyone while encouraging contributions back to the community.

See the [LICENSE.md](LICENSE.md) file for the complete license text.

---

<div align="center">

**Built with ❤️ by the FeedbackBin community**

[⭐ Star us on GitHub](https://github.com/murny/feedbackbin) • [🐛 Report an Issue](https://github.com/murny/feedbackbin/issues) • [💬 Join the Discussion](https://github.com/murny/feedbackbin/discussions)

</div>
