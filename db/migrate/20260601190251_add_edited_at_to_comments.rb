# frozen_string_literal: true

class AddEditedAtToComments < ActiveRecord::Migration[8.2]
  def change
    add_column :comments, :edited_at, :datetime
  end
end
