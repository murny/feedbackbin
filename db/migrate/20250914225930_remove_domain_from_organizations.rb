# frozen_string_literal: true

class RemoveDomainFromOrganizations < ActiveRecord::Migration[8.1]
  def change
    remove_column :organizations, :domain, :string
  end
end
