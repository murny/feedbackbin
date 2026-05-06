# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?

  creds = Rails.application.credentials

  # In the test environment we always register google/facebook (with nil credentials)
  # so OmniAuth.config.test_mode can stub the callbacks without depending on real
  # credentials. OauthHelper#omniauth_provider_available? mirrors this carve-out so
  # the sign-in UI reflects the routes that actually exist.
  if Rails.env.test? || (creds.google_app_id.present? && creds.google_app_secret.present?)
    provider :google_oauth2, creds.google_app_id, creds.google_app_secret, name: "google"
  end

  if Rails.env.test? || (creds.facebook_app_id.present? && creds.facebook_app_secret.present?)
    provider :facebook, creds.facebook_app_id, creds.facebook_app_secret
  end
end
