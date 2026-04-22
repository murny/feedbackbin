# frozen_string_literal: true

class AddOfficialCommentToIdeas < ActiveRecord::Migration[8.2]
  def change
    add_column :ideas, :official_comment_id, :bigint
    add_index :ideas, :official_comment_id
  end
end
