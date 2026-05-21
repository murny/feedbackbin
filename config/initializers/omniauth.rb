# frozen_string_literal: true

OmniAuth.config.logger = Rails.logger

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :developer if Oauth::Providers.available.include?("developer")

  if Oauth::Providers.available.include?("google")
    provider :google_oauth2, Rails.application.credentials.google_app_id, Rails.application.credentials.google_app_secret, name: "google"
  end

  if Oauth::Providers.available.include?("facebook")
    provider :facebook, Rails.application.credentials.facebook_app_id, Rails.application.credentials.facebook_app_secret
  end
end
