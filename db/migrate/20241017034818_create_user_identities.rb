# frozen_string_literal: true

class CreateUserIdentities < ActiveRecord::Migration[8.0]
  def change
    create_table :user_identities do |t|
      t.references :user, null: false, foreign_key: true
      t.string :provider_name, null: false
      t.string :provider_uid, null: false

      t.timestamps

      t.index ["provider_name", "provider_uid"], name: "index_user_identities_on_provider_name_and_provider_uid", unique: true
      t.index ["provider_name", "user_id"], name: "index_user_identities_on_provider_name_and_user_id", unique: true
    end
  end
end
