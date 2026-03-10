# frozen_string_literal: true

class AddRoadmapPublicToAccounts < ActiveRecord::Migration[8.2]
  def change
    add_column :accounts, :roadmap_public, :boolean, default: true, null: false
  end
end
