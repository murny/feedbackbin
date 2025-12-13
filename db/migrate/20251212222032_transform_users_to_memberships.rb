# frozen_string_literal: true

class TransformUsersToMemberships < ActiveRecord::Migration[8.2]
  def change
    # Add new references
    add_reference :users, :identity, null: false, foreign_key: true
    add_reference :users, :account, null: false, foreign_key: true

    # Remove columns that moved to Identity
    remove_index :users, :email_address
    remove_column :users, :email_address, :string
    remove_column :users, :password_digest, :string
    remove_column :users, :super_admin, :boolean

    # Add unique constraint - one identity per account
    add_index :users, [ :identity_id, :account_id ], unique: true
  end
end
