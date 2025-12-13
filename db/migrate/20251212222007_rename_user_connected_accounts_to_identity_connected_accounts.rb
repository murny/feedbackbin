# frozen_string_literal: true

class RenameUserConnectedAccountsToIdentityConnectedAccounts < ActiveRecord::Migration[8.2]
  def change
    # Drop old table and create new one with correct foreign key (SQLite FK limitations)
    drop_table :user_connected_accounts

    create_table :identity_connected_accounts do |t|
      t.references :identity, null: false, foreign_key: false
      t.string :provider_name, null: false
      t.string :provider_uid, null: false

      t.timestamps
    end

    # Add FK explicitly to identities table (not users)
    add_foreign_key :identity_connected_accounts, :identities, column: :identity_id

    add_index :identity_connected_accounts, [ :provider_name, :provider_uid ], unique: true
    add_index :identity_connected_accounts, [ :provider_name, :identity_id ], unique: true,
              name: "idx_identity_connected_accounts_on_provider_identity"
  end
end
