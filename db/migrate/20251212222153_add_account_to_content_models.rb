# frozen_string_literal: true

class AddAccountToContentModels < ActiveRecord::Migration[8.2]
  def change
    # Add account_id to all content models
    add_reference :boards, :account, null: false, foreign_key: true
    add_reference :statuses, :account, null: false, foreign_key: true
    add_reference :ideas, :account, null: false, foreign_key: true
    add_reference :comments, :account, null: false, foreign_key: true
    add_reference :votes, :account, null: false, foreign_key: true
    add_reference :invitations, :account, null: false, foreign_key: true
    add_reference :changelogs, :account, null: false, foreign_key: true

    # Update uniqueness constraints for boards (name unique per account)
    remove_index :boards, :name
    add_index :boards, [ :account_id, :name ], unique: true

    # Update uniqueness constraints for invitations (email unique per account)
    remove_index :invitations, :email
    add_index :invitations, [ :account_id, :email ], unique: true
  end
end
