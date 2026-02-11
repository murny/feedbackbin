# frozen_string_literal: true

class CreateSearchQueries < ActiveRecord::Migration[8.1]
  def change
    create_table :search_queries do |t|
      t.references :account, null: false
      t.references :user, null: false
      t.string :terms, null: false
      t.timestamps
    end

    add_index :search_queries, [ :account_id, :user_id, :terms ],
              unique: true, name: "idx_search_queries_uniqueness"
  end
end
