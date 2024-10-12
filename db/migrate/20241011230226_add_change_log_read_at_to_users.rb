# frozen_string_literal: true

class AddChangeLogReadAtToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :changelogs_read_at, :datetime
  end
end
