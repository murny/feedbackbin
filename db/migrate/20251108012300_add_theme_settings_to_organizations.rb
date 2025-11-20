# frozen_string_literal: true

class AddThemeSettingsToOrganizations < ActiveRecord::Migration[8.1]
  def change
    # Organization theme settings
    add_column :organizations, :theme, :string, default: "system", null: false
    add_column :organizations, :accent_color, :string
    add_column :organizations, :allow_user_theme_choice, :boolean, default: false, null: false

    # Index for theme lookups
    add_index :organizations, :theme
  end
end
