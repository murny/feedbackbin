# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: {unique: true}
      t.string :password_digest, null: false

      t.boolean :verified, null: false, default: false

      t.string :provider
      t.string :uid

      t.references :account, null: false, foreign_key: true

      t.timestamps
    end
  end
end
