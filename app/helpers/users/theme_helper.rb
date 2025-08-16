# frozen_string_literal: true

module Users
  module ThemeHelper
    def theme_options
      [
        [t("themes.system"), "system", "icons/monitor.svg"],
        [t("themes.light"), "light", "icons/sun.svg"],
        [t("themes.dark"), "dark", "icons/moon.svg"]
      ]
    end
  end
end
