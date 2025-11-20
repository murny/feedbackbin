# frozen_string_literal: true

module ThemeHelper
  def effective_theme
    if Current.user && Current.organization&.allow_user_theme_choice?
      Current.user.effective_theme
    else
      Current.organization&.theme || "system"
    end
  end

  def effective_accent_color
    Current.organization&.accent_color_or_default
  end

  def user_can_choose_theme?
    Current.organization&.allow_user_theme_choice? || false
  end

  def theme_preview_class(theme_key)
    case theme_key
    when "light"
      "bg-white text-gray-900"
    when "dark"
      "bg-gray-900 text-white"
    when "purple"
      "bg-[#1e1b2e] text-white"
    when "navy"
      "bg-[#0f172a] text-white"
    when "system"
      "bg-gradient-to-r from-white via-gray-400 to-gray-900 text-gray-900"
    else
      "bg-white text-gray-900"
    end
  end
end
