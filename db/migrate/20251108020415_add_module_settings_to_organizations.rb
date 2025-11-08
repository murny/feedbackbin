# frozen_string_literal: true

class AddModuleSettingsToOrganizations < ActiveRecord::Migration[8.2]
  def change
    # Module toggles
    add_column :organizations, :posts_enabled, :boolean, default: true, null: false
    add_column :organizations, :roadmap_enabled, :boolean, default: true, null: false
    add_column :organizations, :changelog_enabled, :boolean, default: true, null: false

    # Default landing page
    add_column :organizations, :root_path_module, :string, default: "posts", null: false

    # Indexes for frequent lookups
    add_index :organizations, :posts_enabled
    add_index :organizations, :roadmap_enabled
    add_index :organizations, :changelog_enabled
  end
end
