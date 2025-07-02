# frozen_string_literal: true

class AddTagsAndMetadataToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :pinned, :boolean, default: false, null: false
    add_column :posts, :views_count, :integer, default: 0, null: false
    add_column :posts, :status_color, :string

    add_index :posts, :pinned
    add_index :posts, :views_count
  end
end