# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer unless Rails.env.production?
  provider :google_oauth2,
    Rails.application.credentials.google_app_id,
    Rails.application.credentials.google_app_secret,
    name: "google"
  provider :facebook,
    Rails.application.credentials.facebook_app_id,
    Rails.application.credentials.facebook_app_secret
end
