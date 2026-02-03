# frozen_string_literal: true

class CreateTaggings < ActiveRecord::Migration[8.2]
  def change
    create_table :taggings do |t|
      t.bigint :account_id, null: false
      t.bigint :tag_id, null: false
      t.bigint :idea_id, null: false
      t.timestamps

      t.index [ :account_id ]
      t.index [ :tag_id ]
      t.index [ :idea_id, :tag_id ], unique: true
    end
  end
end
