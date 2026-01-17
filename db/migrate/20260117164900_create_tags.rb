# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[8.2]
  def change
    create_table :tags do |t|
      t.bigint :account_id, null: false
      t.string :title, null: false
      t.timestamps

      t.index [ :account_id ]
      t.index [ :account_id, :title ], unique: true
    end
  end
end
