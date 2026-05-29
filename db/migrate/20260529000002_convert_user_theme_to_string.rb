# frozen_string_literal: true

class ConvertUserThemeToString < ActiveRecord::Migration[8.2]
  MAPPING = { 0 => "system", 1 => "light", 2 => "dark" }.freeze

  def up
    add_column :users, :theme_tmp, :string, default: "system", null: false
    MAPPING.each { |ordinal, label| execute("UPDATE users SET theme_tmp = '#{label}' WHERE theme = #{ordinal}") }
    remove_column :users, :theme
    rename_column :users, :theme_tmp, :theme
  end

  def down
    add_column :users, :theme_tmp, :integer, default: 0, null: false
    MAPPING.each { |ordinal, label| execute("UPDATE users SET theme_tmp = #{ordinal} WHERE theme = '#{label}'") }
    remove_column :users, :theme
    rename_column :users, :theme_tmp, :theme
  end
end
