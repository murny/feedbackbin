# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[8.2]
  def change
    create_table :events do |t|
      t.string :action, null: false
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :organization, null: false, foreign_key: true
      t.references :eventable, polymorphic: true, null: false
      t.json :particulars, default: {}

      t.timestamps
    end

    add_index :events, [ :organization_id, :created_at ]
    add_index :events, [ :eventable_type, :eventable_id, :created_at ]
    add_index :events, [ :creator_id, :created_at ]
    add_index :events, :action
  end
end
