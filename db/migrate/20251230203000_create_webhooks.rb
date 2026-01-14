# frozen_string_literal: true

class CreateWebhooks < ActiveRecord::Migration[8.2]
  def change
    create_table :webhooks do |t|
      t.bigint :account_id, null: false
      t.bigint :board_id  # Optional: scope to specific board
      t.string :name, null: false
      t.string :url, null: false
      t.string :signing_secret, null: false
      t.json :subscribed_actions, default: []
      t.boolean :active, default: true, null: false
      t.text :description
      t.timestamps
    end

    add_index :webhooks, :account_id
    add_index :webhooks, :board_id
    add_index :webhooks, :active
    add_index :webhooks, [ :account_id, :active ]

    add_foreign_key :webhooks, :accounts
    add_foreign_key :webhooks, :boards
  end
end
