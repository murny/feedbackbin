# frozen_string_literal: true

# Check out the Rails guides for setting locale by domain or subdomain
# https://guides.rubyonrails.org/i18n.html#setting-the-locale-from-the-domain-name

module SetLocale
  extend ActiveSupport::Concern

  included do
    before_action :set_locale
  end

  def set_locale
    I18n.locale = find_locale
    Pagy::I18n.locale = I18n.locale.to_s
  end

  private

    def find_locale
      locale_from_params || locale_from_user || locale_from_header || I18n.default_locale
    end

    def locale_from_params
      permit_locale(params[:locale])
    end

    def locale_from_user
      return unless authenticated? && Current.user.present?
      permit_locale(Current.user.preferred_language)
    end

    # Extract the full locale (including region code)
    # Handles `pt-BR` by falling back to `pt`
    def locale_from_header
      locale = request.env.fetch("HTTP_ACCEPT_LANGUAGE", "").scan(/^[a-z]{2}(?:-[a-zA-Z]{2})?/).first
      permit_locale(locale) || permit_locale(locale&.split("-")&.first)
    end

    # Makes sure locale is in the available locales list
    def permit_locale(locale)
      locale.presence_in(I18n.config.available_locales_set)
    end
end
