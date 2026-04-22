# frozen_string_literal: true

class AddCommentsLockedToIdeas < ActiveRecord::Migration[8.2]
  def change
    add_column :ideas, :comments_locked, :boolean, default: false, null: false
    add_index :ideas, :comments_locked
  end
end
