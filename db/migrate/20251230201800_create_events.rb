class CreateEvents < ActiveRecord::Migration[8.2]
  def change
    create_table :events do |t|
      t.bigint :account_id, null: false
      t.string :action, null: false
      t.bigint :board_id, null: false
      t.bigint :creator_id, null: false
      t.bigint :eventable_id, null: false
      t.string :eventable_type, null: false
      t.json :particulars, default: {}
      t.timestamps
    end

    add_index :events, :account_id
    add_index :events, :board_id
    add_index :events, :creator_id
    add_index :events, :action
    add_index :events, [:eventable_type, :eventable_id]
    add_index :events, [:board_id, :action, :created_at]

    add_foreign_key :events, :accounts
    add_foreign_key :events, :boards
    add_foreign_key :events, :users, column: :creator_id
  end
end
