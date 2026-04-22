# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?

  creds = Rails.application.credentials

  if Rails.env.test? || (creds.google_app_id.present? && creds.google_app_secret.present?)
    provider :google_oauth2, creds.google_app_id, creds.google_app_secret, name: "google"
  end

  if Rails.env.test? || (creds.facebook_app_id.present? && creds.facebook_app_secret.present?)
    provider :facebook, creds.facebook_app_id, creds.facebook_app_secret
  end
end
