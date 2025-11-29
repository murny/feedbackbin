# frozen_string_literal: true

class RemoveCounterCacheColumns < ActiveRecord::Migration[8.0]
  def change
    remove_column :posts, :comments_count, :integer
    remove_column :posts, :likes_count, :integer
    remove_column :comments, :likes_count, :integer
  end
end
