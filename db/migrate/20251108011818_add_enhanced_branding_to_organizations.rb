# frozen_string_literal: true

class AddEnhancedBrandingToOrganizations < ActiveRecord::Migration[8.2]
  def change
    # Logo display options
    add_column :organizations, :logo_display_mode, :string, default: "logo_and_name", null: false
    add_column :organizations, :logo_link, :string

    # Note: favicon and og_image use ActiveStorage, no columns needed
  end
end
