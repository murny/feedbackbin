---
layout: docs
title: Environment Variables
description: "Configure FeedbackBin with environment variables for settings, performance tuning, and feature toggles."
---

FeedbackBin is configured entirely through environment variables. Set these in your deployment environment or `.env` file.

## Required Variables

<div class="overflow-x-auto">
  <table class="w-full border-collapse border border-border">
    <thead>
      <tr class="bg-muted">
        <th class="border border-border px-4 py-3 text-left font-semibold">Variable</th>
        <th class="border border-border px-4 py-3 text-left font-semibold">Purpose</th>
        <th class="border border-border px-4 py-3 text-left font-semibold">Example</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm">`RAILS_ENV`</td>
        <td class="border border-border px-4 py-3">Rails environment</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`production`</td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm">`RAILS_MASTER_KEY`</td>
        <td class="border border-border px-4 py-3">Rails credentials encryption key</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`abc123...` (64 chars)</td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm">`SELF_HOSTED`</td>
        <td class="border border-border px-4 py-3">Enable self-hosted features</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`true`</td>
      </tr>
    </tbody>
  </table>
</div>

## Performance Settings

<div class="overflow-x-auto">
  <table class="w-full border-collapse border border-border">
    <thead>
      <tr class="bg-muted">
        <th class="border border-border px-4 py-3 text-left font-semibold">Variable</th>
        <th class="border border-border px-4 py-3 text-left font-semibold">Purpose</th>
        <th class="border border-border px-4 py-3 text-left font-semibold">Default</th>
        <th class="border border-border px-4 py-3 text-left font-semibold">Recommended</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm">`WEB_CONCURRENCY`</td>
        <td class="border border-border px-4 py-3">Number of Puma workers</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`1`</td>
        <td class="border border-border px-4 py-3">`2-4` (based on CPU cores)</td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm">`RAILS_MAX_THREADS`</td>
        <td class="border border-border px-4 py-3">Max threads per worker</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`5`</td>
        <td class="border border-border px-4 py-3">`5-10`</td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm">`DB_POOL`</td>
        <td class="border border-border px-4 py-3">Database connection pool size</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`5`</td>
        <td class="border border-border px-4 py-3">Same as `RAILS_MAX_THREADS`</td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm">`SOLID_QUEUE_IN_PUMA`</td>
        <td class="border border-border px-4 py-3">Run background jobs in web process</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`true`</td>
        <td class="border border-border px-4 py-3">`true` (single server), `false` (multi-server)</td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm">`JOB_CONCURRENCY`</td>
        <td class="border border-border px-4 py-3">Background job worker count</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`1`</td>
        <td class="border border-border px-4 py-3">`2-5`</td>
      </tr>
    </tbody>
  </table>
</div>

## Security Settings

<div class="overflow-x-auto">
  <table class="w-full border-collapse border border-border">
    <thead>
      <tr class="bg-muted">
        <th class="border border-border px-4 py-3 text-left font-semibold">Variable</th>
        <th class="border border-border px-4 py-3 text-left font-semibold">Purpose</th>
        <th class="border border-border px-4 py-3 text-left font-semibold">Default</th>
        <th class="border border-border px-4 py-3 text-left font-semibold">Notes</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm">`FORCE_SSL`</td>
        <td class="border border-border px-4 py-3">Force HTTPS redirects</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`true`</td>
        <td class="border border-border px-4 py-3">Set to `false` for development only</td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm">`ASSUME_SSL`</td>
        <td class="border border-border px-4 py-3">Assume SSL termination at proxy</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`true`</td>
        <td class="border border-border px-4 py-3">Keep `true` for reverse proxy setups</td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm">`SECRET_KEY_BASE`</td>
        <td class="border border-border px-4 py-3">Session encryption key</td>
        <td class="border border-border px-4 py-3">Generated</td>
        <td class="border border-border px-4 py-3">Auto-generated from `RAILS_MASTER_KEY`</td>
      </tr>
    </tbody>
  </table>
</div>

## Application Settings

<div class="overflow-x-auto">
  <table class="w-full border-collapse border border-border">
    <thead>
      <tr class="bg-muted">
        <th class="border border-border px-4 py-3 text-left font-semibold">Variable</th>
        <th class="border border-border px-4 py-3 text-left font-semibold">Purpose</th>
        <th class="border border-border px-4 py-3 text-left font-semibold">Default</th>
        <th class="border border-border px-4 py-3 text-left font-semibold">Example</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm">`APP_NAME`</td>
        <td class="border border-border px-4 py-3">Application name in UI</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`FeedbackBin`</td>
        <td class="border border-border px-4 py-3">`Acme Feedback`</td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm">`APP_TAGLINE`</td>
        <td class="border border-border px-4 py-3">Subtitle/description</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`Feedback Management`</td>
        <td class="border border-border px-4 py-3">`Customer Insights Hub`</td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm">`SUPPORT_EMAIL`</td>
        <td class="border border-border px-4 py-3">Contact email for support</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`support@feedbackbin.com`</td>
        <td class="border border-border px-4 py-3">`help@yourcompany.com`</td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm">`RAILS_LOG_LEVEL`</td>
        <td class="border border-border px-4 py-3">Logging verbosity</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`info`</td>
        <td class="border border-border px-4 py-3">`debug`, `warn`, `error`</td>
      </tr>
    </tbody>
  </table>
</div>

## Feature Toggles

<div class="overflow-x-auto">
  <table class="w-full border-collapse border border-border">
    <thead>
      <tr class="bg-muted">
        <th class="border border-border px-4 py-3 text-left font-semibold">Variable</th>
        <th class="border border-border px-4 py-3 text-left font-semibold">Purpose</th>
        <th class="border border-border px-4 py-3 text-left font-semibold">Default</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm">`ALLOW_SIGNUP`</td>
        <td class="border border-border px-4 py-3">Enable user registration</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`true`</td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm">`REQUIRE_EMAIL_CONFIRMATION`</td>
        <td class="border border-border px-4 py-3">Require email verification</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`true`</td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm">`ENABLE_NOTIFICATIONS`</td>
        <td class="border border-border px-4 py-3">Enable email notifications</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`true`</td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm">`ALLOW_GUEST_POSTS`</td>
        <td class="border border-border px-4 py-3">Allow anonymous feedback</td>
        <td class="border border-border px-4 py-3 font-mono text-sm">`false`</td>
      </tr>
    </tbody>
  </table>
</div>

## How to Set Environment Variables

### Using Environment Files

```bash
# .env.production
RAILS_ENV=production
SELF_HOSTED=true
WEB_CONCURRENCY=2
RAILS_MAX_THREADS=10
```

### Using Docker/Kamal

```yaml
# Docker Compose
environment:
  - RAILS_ENV=production
  - SELF_HOSTED=true
  - WEB_CONCURRENCY=2

# Kamal deploy.yml
env:
  clear:
    SELF_HOSTED: true
    WEB_CONCURRENCY: 2
  secret:
    - RAILS_MASTER_KEY
```

### Using Rails Credentials

For sensitive configuration, use Rails credentials:

```bash
EDITOR=nano bin/rails credentials:edit --environment production
```

