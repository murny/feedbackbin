# frozen_string_literal: true

class CreateWatches < ActiveRecord::Migration[8.2]
  def change
    create_table :watches do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :idea, null: false, foreign_key: true
      t.boolean :watching, default: true, null: false

      t.timestamps
    end

    add_index :watches, [ :user_id, :idea_id ], unique: true
  end
end
