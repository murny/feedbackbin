# frozen_string_literal: true

class AddEnhancedBrandingToOrganizations < ActiveRecord::Migration[8.2]
  def change
    add_column :organizations, :show_company_name, :boolean, default: true, null: false
    add_column :organizations, :logo_link, :string
  end
end
