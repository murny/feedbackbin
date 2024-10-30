# frozen_string_literal: true

class AddPreferencesToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :time_zone, :string
    add_column :users, :preferred_language, :string
    add_column :users, :theme, :integer, default: 0, null: false
  end
end
