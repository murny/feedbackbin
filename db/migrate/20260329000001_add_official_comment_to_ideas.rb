# frozen_string_literal: true

class AddOfficialCommentToIdeas < ActiveRecord::Migration[8.2]
  def change
    add_reference :ideas, :official_comment, foreign_key: { to_table: :comments }, null: true
  end
end
