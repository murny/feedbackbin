# frozen_string_literal: true

class AddInternalToComments < ActiveRecord::Migration[8.2]
  def change
    add_column :comments, :internal, :boolean, default: false, null: false
    add_index :comments, :internal
  end
end
