# frozen_string_literal: true

class CreateMentions < ActiveRecord::Migration[8.2]
  def change
    create_table :mentions do |t|
      t.references :account, null: false
      t.references :mentioner, null: false
      t.references :mentionee, null: false
      t.references :source, polymorphic: true, null: false

      t.timestamps
    end

    add_index :mentions, [ :source_type, :source_id, :mentionee_id ], unique: true
  end
end
