# frozen_string_literal: true

module OauthHelper
  def omniauth_provider_available?(provider)
    case provider.to_s
    when "developer"
      !Rails.env.production?
    when "google"
      creds = Rails.application.credentials
      Rails.env.test? || (creds.google_app_id.present? && creds.google_app_secret.present?)
    when "facebook"
      creds = Rails.application.credentials
      Rails.env.test? || (creds.facebook_app_id.present? && creds.facebook_app_secret.present?)
    else
      false
    end
  end
end
