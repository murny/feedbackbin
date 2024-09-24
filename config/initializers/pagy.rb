# frozen_string_literal: true

require "pagy/extras/overflow"
Pagy::DEFAULT[:overflow] = :last_page

Pagy::I18n.load(locale: "en", filepath: "config/locales/en.yml")
