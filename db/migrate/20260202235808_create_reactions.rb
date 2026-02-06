# frozen_string_literal: true

class CreateReactions < ActiveRecord::Migration[8.2]
  def change
    create_table :reactions do |t|
      t.references :account, null: false
      t.references :reacter, null: false
      t.references :reactable, polymorphic: true, null: false
      t.string :content, null: false, limit: 16

      t.timestamps
    end

    add_index :reactions, [ :reacter_id, :reactable_type, :reactable_id, :content ],
              unique: true, name: "index_reactions_uniqueness"
  end
end
