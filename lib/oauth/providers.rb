# frozen_string_literal: true

module Oauth
  module Providers
    def self.available
      @available ||= [].tap do |list|
        list << "developer" unless Rails.env.production?
        list << "google"   if register_google?
        list << "facebook" if register_facebook?
      end.freeze
    end

    def self.register_google?
      Rails.env.test? || (Rails.application.credentials.google_app_id.present? && Rails.application.credentials.google_app_secret.present?)
    end

    def self.register_facebook?
      Rails.env.test? || (Rails.application.credentials.facebook_app_id.present? && Rails.application.credentials.facebook_app_secret.present?)
    end
  end
end
