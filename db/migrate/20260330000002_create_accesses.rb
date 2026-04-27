# frozen_string_literal: true

class CreateAccesses < ActiveRecord::Migration[8.2]
  def change
    create_table :accesses do |t|
      t.bigint :account_id, null: false
      t.bigint :board_id, null: false
      t.bigint :user_id, null: false
      t.integer :involvement, default: 0, null: false
      t.datetime :accessed_at

      t.timestamps
    end

    add_index :accesses, :account_id
    add_index :accesses, [ :board_id, :user_id ], unique: true
    add_index :accesses, [ :user_id, :accessed_at ]
    add_index :accesses, [ :account_id, :board_id ]
  end
end
