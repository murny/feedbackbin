class CreateNotifications < ActiveRecord::Migration[8.2]
  def change
    create_table :notifications do |t|
      t.bigint :user_id, null: false
      t.bigint :creator_id, null: false
      t.bigint :source_id, null: false
      t.string :source_type, null: false  # "Event" for now, "Mention" later
      t.datetime :read_at
      t.timestamps
    end

    add_index :notifications, :user_id
    add_index :notifications, :creator_id
    add_index :notifications, [:source_type, :source_id]
    add_index :notifications, [:user_id, :read_at]
    add_index :notifications, [:user_id, :created_at]

    add_foreign_key :notifications, :users, column: :user_id
    add_foreign_key :notifications, :users, column: :creator_id
  end
end
