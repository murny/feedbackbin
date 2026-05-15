---
layout: page
title: Development Guide
permalink: /docs/development/
description: "Learn how to set up FeedbackBin for local development, run tests, and contribute to the project."
---

# Development Guide

This guide covers setting up FeedbackBin for local development.

## Setting Up

First, get everything installed and configured:

```sh
bin/setup
```

This will:
- Install Ruby dependencies via Bundler
- Prepare the database
- Clean up logs and temp files

Then run the development server:

```sh
bin/dev
```

You'll be able to access the app at [http://localhost:3000](http://localhost:3000).

### Resetting the Database

To reset the database and re-seed with sample data:

```sh
bin/setup --reset
```

## Logging In

FeedbackBin uses passwordless magic link authentication in development. To log in:

1. Enter an email address (e.g., `shane@example.com`)
2. Check the Rails console for the magic link
3. Click the link or copy the verification code

## Running Tests

For fast feedback loops, run the test suite with:

```sh
bin/rails test
```

To run system tests (browser-based):

```sh
bin/rails test:system
```

The full continuous integration pipeline can be run with:

```sh
bin/ci
```

This runs linting, security checks, and all tests.

## Code Quality

### Ruby Code

```sh
# Check Ruby code style
bin/rubocop

# Auto-fix Ruby style issues
bin/rubocop -a
```

### ERB Templates

```sh
# Check ERB templates
bin/erb_lint --lint-all

# Auto-fix ERB issues (use with caution)
bin/erb_lint --lint-all -a
```

### Herb (optional editor tooling)

[Herb](https://herb-tools.dev) is a Prism-based HTML+ERB toolchain. We use the Ruby gem for local parser checks, and the language server for editor diagnostics. `erb_lint` remains the canonical linter in CI.

The Ruby gem (already in the `Gemfile`) gives you parser + structural validation with no extra setup:

```sh
# Parse-check all ERB templates (Ruby-only, no Node required)
bin/herb analyze app/
```

For the full rule-based linter, formatter, and language server, install the Node packages per-developer. These are not committed to the repo and not run in CI.

```sh
# Install the linter + formatter globally (one-time, requires Node.js)
npm install -g @herb-tools/linter @herb-tools/formatter

# Lint with the configurable rule set
bin/herb lint app/

# Auto-correct fixable offenses (review the diff before committing)
bin/herb lint app/ --fix
```

Editor integration is also installed per-developer:

- **VS Code**: install the [`marcoroth.herb-lsp`](https://marketplace.visualstudio.com/items?itemName=marcoroth.herb-lsp) extension (bundles the language server, no separate npm install needed)
- **Zed / Neovim / others**: supported via the Herb language server (`bin/herb lsp`, requires `@herb-tools/language-server` on PATH)

### Internationalization

```sh
# Check I18n file health
bin/i18n-tasks health

# Normalize I18n files
bin/i18n-tasks normalize
```

## Security Checks

```sh
# Static security analysis
bin/brakeman

# Check for vulnerable gems
bin/bundler-audit

# JavaScript vulnerability check
bin/importmap audit

# Secret scan (writes report to tmp/gitleaks-report.json)
bin/gitleaks-audit
```

If `bin/gitleaks-audit` fails, inspect `tmp/gitleaks-report.json` and remediate before merging:

1. Revoke and rotate any real secret immediately.
2. Remove the secret from source and commit a fix.
3. If the secret was committed, rewrite history to purge it, then rotate credentials.
4. If it's a false positive, use a documented suppression workflow (for example via tuned gitleaks rules) and explain why in the PR.

## Database Operations

```sh
# Create and migrate database
bin/rails db:create db:migrate

# Seed with sample data
bin/rails db:seed

# Reset database (drops, creates, migrates, seeds)
bin/rails db:reset

# Prepare test database
env RAILS_ENV=test bin/rails db:seed:replant
```

## Background Jobs

FeedbackBin uses Solid Queue for background job processing.

By default, `bin/dev` runs with Solid Queue enabled in Puma.

If you want to run jobs in a separate process instead:

```sh
# Disable in-Puma queue runner for this shell
SOLID_QUEUE_IN_PUMA=false bin/dev
```

Then, in a second terminal, start the worker:

```sh
bin/jobs
```

## Outbound Emails

You can view email previews at [http://localhost:3000/rails/mailers](http://localhost:3000/rails/mailers).

In development, emails are captured by the `letter_opener` gem and will open
automatically in your browser.

## Project Structure

### Key Directories

- `app/models/` - Domain models
- `app/controllers/` - Request handlers
- `app/views/` - ERB templates
- `app/components/` - ViewComponent UI components
- `config/locales/` - I18n translation files
- `test/` - Test suite

### Configuration Files

- `config/database.yml` - Database configuration
- `config/credentials.yml.enc` - Encrypted credentials
- `config/deploy.yml` - Kamal deployment configuration

## Useful Commands

| Command | Description |
|---------|-------------|
| `bin/setup` | Set up the project |
| `bin/setup --reset` | Set up and reset database |
| `bin/dev` | Start development server |
| `bin/jobs` | Start Solid Queue worker (optional separate process) |
| `bin/rails test` | Run test suite |
| `bin/ci` | Run full CI pipeline |
| `bin/rubocop` | Check Ruby code style |
| `bin/rails console` | Open Rails console |
| `bin/rails credentials:edit` | Edit encrypted credentials |

## Next Steps

- Read the [Contributing guide](../CONTRIBUTING.md) for contribution guidelines
- Check out deployment guides: [Docker](docker-deployment.md) | [Kamal](kamal-deployment.md)
