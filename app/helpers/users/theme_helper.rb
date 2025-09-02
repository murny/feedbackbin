# frozen_string_literal: true

module Users
  module ThemeHelper
    def theme_options
      [
        [ t("themes.system"), "system", "monitor" ],
        [ t("themes.light"), "light", "sun" ],
        [ t("themes.dark"), "dark", "moon" ]
      ]
    end
  end
end
