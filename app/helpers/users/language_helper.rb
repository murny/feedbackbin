# frozen_string_literal: true

module Users
  module LanguageHelper
    LANGUAGES = {
      en: "English",
      fr: "French",
      nl: "Dutch"
    }

    def language_options
      LANGUAGES.slice(*I18n.available_locales).invert.to_a
    end
  end
end
