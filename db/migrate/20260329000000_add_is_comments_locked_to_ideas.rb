# frozen_string_literal: true

class AddIsCommentsLockedToIdeas < ActiveRecord::Migration[8.2]
  def change
    add_column :ideas, :is_comments_locked, :boolean, default: false, null: false
    add_index :ideas, :is_comments_locked
  end
end
