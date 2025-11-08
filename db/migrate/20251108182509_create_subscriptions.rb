# frozen_string_literal: true

class CreateSubscriptions < ActiveRecord::Migration[8.2]
  def change
    create_table :subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subscribable, polymorphic: true, null: false
      t.datetime :subscribed_at
      t.datetime :unsubscribed_at

      t.timestamps
    end

    add_index :subscriptions, [ :user_id, :subscribable_type, :subscribable_id ], unique: true, name: "index_subscriptions_on_user_and_subscribable"
    add_index :subscriptions, :subscribed_at
    add_index :subscriptions, :unsubscribed_at
  end
end
