# frozen_string_literal: true

class AddThemePreferenceToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :theme_preference, :string, default: "organization", null: false
    add_index :users, :theme_preference
  end
end
