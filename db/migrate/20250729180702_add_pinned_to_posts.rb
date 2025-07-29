# frozen_string_literal: true

class AddPinnedToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :posts, :pinned, :boolean, default: false, null: false
    add_index :posts, :pinned
  end
end
