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
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>RAILS_ENV</code></td>
        <td class="border border-border px-4 py-3">Rails environment</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>production</code></td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>RAILS_MASTER_KEY</code></td>
        <td class="border border-border px-4 py-3">Rails credentials encryption key</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>abc123...</code> (64 chars)</td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>SELF_HOSTED</code></td>
        <td class="border border-border px-4 py-3">Enable self-hosted features</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>true</code></td>
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
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>WEB_CONCURRENCY</code></td>
        <td class="border border-border px-4 py-3">Number of Puma workers</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>1</code></td>
        <td class="border border-border px-4 py-3"><code>2-4</code> (based on CPU cores)</td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>RAILS_MAX_THREADS</code></td>
        <td class="border border-border px-4 py-3">Max threads per worker</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>5</code></td>
        <td class="border border-border px-4 py-3"><code>5-10</code></td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>DB_POOL</code></td>
        <td class="border border-border px-4 py-3">Database connection pool size</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>5</code></td>
        <td class="border border-border px-4 py-3">Same as <code>RAILS_MAX_THREADS</code></td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>SOLID_QUEUE_IN_PUMA</code></td>
        <td class="border border-border px-4 py-3">Run background jobs in web process</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>true</code></td>
        <td class="border border-border px-4 py-3"><code>true</code> (single server), <code>false</code> (multi-server)</td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>JOB_CONCURRENCY</code></td>
        <td class="border border-border px-4 py-3">Background job worker count</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>1</code></td>
        <td class="border border-border px-4 py-3"><code>2-5</code></td>
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
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>FORCE_SSL</code></td>
        <td class="border border-border px-4 py-3">Force HTTPS redirects</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>true</code></td>
        <td class="border border-border px-4 py-3">Set to <code>false</code> for development only</td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>ASSUME_SSL</code></td>
        <td class="border border-border px-4 py-3">Assume SSL termination at proxy</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>true</code></td>
        <td class="border border-border px-4 py-3">Keep <code>true</code> for reverse proxy setups</td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>SECRET_KEY_BASE</code></td>
        <td class="border border-border px-4 py-3">Session encryption key</td>
        <td class="border border-border px-4 py-3">Generated</td>
        <td class="border border-border px-4 py-3">Auto-generated from <code>RAILS_MASTER_KEY</code></td>
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
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>APP_NAME</code></td>
        <td class="border border-border px-4 py-3">Application name in UI</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>FeedbackBin</code></td>
        <td class="border border-border px-4 py-3"><code>Acme Feedback</code></td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>APP_TAGLINE</code></td>
        <td class="border border-border px-4 py-3">Subtitle/description</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>Feedback Management</code></td>
        <td class="border border-border px-4 py-3"><code>Customer Insights Hub</code></td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>SUPPORT_EMAIL</code></td>
        <td class="border border-border px-4 py-3">Contact email for support</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>support@feedbackbin.com</code></td>
        <td class="border border-border px-4 py-3"><code>help@yourcompany.com</code></td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>RAILS_LOG_LEVEL</code></td>
        <td class="border border-border px-4 py-3">Logging verbosity</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>info</code></td>
        <td class="border border-border px-4 py-3"><code>debug</code>, <code>warn</code>, <code>error</code></td>
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
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>ALLOW_SIGNUP</code></td>
        <td class="border border-border px-4 py-3">Enable user registration</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>true</code></td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>REQUIRE_EMAIL_CONFIRMATION</code></td>
        <td class="border border-border px-4 py-3">Require email verification</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>true</code></td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>ENABLE_NOTIFICATIONS</code></td>
        <td class="border border-border px-4 py-3">Enable email notifications</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>true</code></td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>ALLOW_GUEST_POSTS</code></td>
        <td class="border border-border px-4 py-3">Allow anonymous feedback</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>false</code></td>
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

