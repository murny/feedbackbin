---
layout: docs
title: Email Configuration
description: "Configure SMTP for email notifications, password resets, and user invitations in FeedbackBin."
---

Configure SMTP to enable email notifications, password resets, and user invitations.

## SMTP Settings

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
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>SMTP_HOST</code></td>
        <td class="border border-border px-4 py-3">SMTP server hostname</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>smtp.gmail.com</code></td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>SMTP_PORT</code></td>
        <td class="border border-border px-4 py-3">SMTP server port</td>
        <td class="border border-border px-4 py-3"><code>587</code> (StartTLS), <code>465</code> (SSL)</td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>SMTP_USERNAME</code></td>
        <td class="border border-border px-4 py-3">SMTP authentication username</td>
        <td class="border border-border px-4 py-3"><code>your-email@example.com</code></td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>SMTP_PASSWORD</code></td>
        <td class="border border-border px-4 py-3">SMTP authentication password</td>
        <td class="border border-border px-4 py-3"><code>your-app-password</code></td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>SMTP_DOMAIN</code></td>
        <td class="border border-border px-4 py-3">HELO domain</td>
        <td class="border border-border px-4 py-3"><code>example.com</code></td>
      </tr>
      <tr class="bg-muted/50">
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>SMTP_AUTHENTICATION</code></td>
        <td class="border border-border px-4 py-3">Authentication method</td>
        <td class="border border-border px-4 py-3"><code>plain</code>, <code>login</code>, <code>cram_md5</code></td>
      </tr>
      <tr>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>SMTP_ENABLE_STARTTLS_AUTO</code></td>
        <td class="border border-border px-4 py-3">Use StartTLS</td>
        <td class="border border-border px-4 py-3 font-mono text-sm"><code>true</code></td>
      </tr>
    </tbody>
  </table>
</div>

## Popular Email Providers

### Gmail/Google Workspace

```bash
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_DOMAIN=gmail.com
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

**Note:** Use an [App Password](https://support.google.com/accounts/answer/185833) instead of your regular password.

### SendGrid

```bash
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USERNAME=apikey
SMTP_PASSWORD=your-sendgrid-api-key
SMTP_DOMAIN=your-domain.com
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

### Mailgun

```bash
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_USERNAME=your-mailgun-username
SMTP_PASSWORD=your-mailgun-password
SMTP_DOMAIN=your-domain.com
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

### Postmark

```bash
SMTP_HOST=smtp.postmarkapp.com
SMTP_PORT=587
SMTP_USERNAME=your-server-token
SMTP_PASSWORD=your-server-token
SMTP_DOMAIN=your-domain.com
SMTP_AUTHENTICATION=cram_md5
SMTP_ENABLE_STARTTLS_AUTO=true
```

## Using Rails Credentials

For secure credential storage, use Rails credentials:

```bash
EDITOR=nano bin/rails credentials:edit --environment production
```

```yaml
smtp:
  host: "smtp.gmail.com"
  port: 587
  username: "your-email@gmail.com"
  password: "your-app-password"
  domain: "your-domain.com"
  authentication: "plain"
  enable_starttls_auto: true
```

## Testing Email Configuration

Test your email setup from the Rails console:

```bash
# Access Rails console
bin/rails console

# Test email delivery
ActionMailer::Base.mail(
  from: 'test@example.com',
  to: 'your-email@example.com',
  subject: 'FeedbackBin Test Email',
  body: 'This is a test email from FeedbackBin.'
).deliver_now
```

## Troubleshooting

### Email not sending
- Test SMTP connection manually
- Check firewall allows outbound SMTP ports (587, 465)
- Verify SMTP credentials and settings

### Authentication failures
- Ensure you're using app passwords for Gmail
- Check username/password are correct
- Verify authentication method matches provider requirements

### SSL/TLS errors
- Use port 587 with StartTLS for most providers
- Use port 465 for SSL connections
- Check `SMTP_ENABLE_STARTTLS_AUTO` setting