# frozen_string_literal: true

class CreateIdentities < ActiveRecord::Migration[8.2]
  def change
    create_table :identities do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.boolean :super_admin, default: false, null: false

      t.timestamps
    end

    add_index :identities, :email_address, unique: true
  end
end
