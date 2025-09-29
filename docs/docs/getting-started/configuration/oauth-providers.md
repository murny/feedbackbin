---
layout: docs
title: OAuth Providers
description: "Enable social login with Google, Facebook, and other OAuth providers to reduce authentication friction."
---

Enable social login to reduce friction for your users. FeedbackBin supports multiple OAuth providers.

## Google OAuth Setup

### 1. Create Google OAuth Application

- Visit [Google Cloud Console](https://console.cloud.google.com/)
- Create a new project or select existing one
- Go to "Credentials" → "Create Credentials" → "OAuth 2.0 Client IDs" (no additional APIs are required for basic OAuth)

### 2. Configure OAuth Settings

- **Application type**: Web application
- **Name**: FeedbackBin
- **Authorized redirect URIs**: `https://your-domain.com/auth/google/callback`

### 3. Add Credentials

**Using Rails Credentials:**
```bash
EDITOR=nano bin/rails credentials:edit --environment production
```

```yaml
google_client_id: "your-client-id.googleusercontent.com"
google_client_secret: "your-client-secret"
```

**Using Environment Variables:**
```bash
GOOGLE_CLIENT_ID=your-client-id.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-client-secret
```

## Facebook OAuth Setup

### 1. Create Facebook App

- Visit [Facebook Developers](https://developers.facebook.com/)
- Create a new app → "Consumer" type
- Add "Facebook Login" product

### 2. Configure Facebook Login

- **Valid OAuth Redirect URIs**: `https://your-domain.com/auth/facebook/callback`
- **Client OAuth Login**: Yes
- **Web OAuth Login**: Yes

### 3. Add Credentials

**Using Rails Credentials:**
```yaml
facebook_app_id: "your-app-id"
facebook_app_secret: "your-app-secret"
```

**Using Environment Variables:**
```bash
FACEBOOK_APP_ID=your-app-id
FACEBOOK_APP_SECRET=your-app-secret
```

## Testing OAuth Setup

1. **Restart your application** after adding credentials
2. **Visit the login page** - you should see OAuth provider buttons
3. **Test the login flow** with a test account
4. **Check logs** for any authentication errors

## Troubleshooting

### "redirect_uri_mismatch" error
- Verify redirect URI exactly matches what's configured in OAuth provider
- Check for trailing slashes, HTTP vs HTTPS
- Ensure domain matches exactly

### "invalid_client" error
- Double-check client ID and secret
- Verify credentials are properly encrypted/set
- Check that OAuth app is active in provider console

### Missing OAuth buttons
- Ensure credentials are set correctly
- Restart the application after adding credentials
- Check Rails logs for configuration errors