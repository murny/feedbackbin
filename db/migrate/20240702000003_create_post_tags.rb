# frozen_string_literal: true

class CreatePostTags < ActiveRecord::Migration[8.0]
  def change
    create_table :post_tags do |t|
      t.references :post, null: false, foreign_key: true
      t.references :tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :post_tags, [:post_id, :tag_id], unique: true
    add_index :post_tags, [:tag_id, :post_id]
  end
end