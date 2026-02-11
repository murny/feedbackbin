# frozen_string_literal: true

class CreateSearchRecords < ActiveRecord::Migration[8.1]
  def change
    create_table :search_records do |t|
      t.references :account, null: false
      t.references :board, null: false
      t.bigint :idea_id, null: false
      t.references :searchable, polymorphic: true, null: false
      t.text :title
      t.text :content
      t.timestamps
    end

    add_index :search_records, [ :account_id, :searchable_type, :searchable_id ],
              unique: true, name: "idx_search_records_uniqueness"
    add_index :search_records, :idea_id
  end
end
