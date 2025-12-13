# frozen_string_literal: true

class UpdateSessionsForIdentity < ActiveRecord::Migration[8.2]
  def change
    # Add identity reference
    add_reference :sessions, :identity, null: false, foreign_key: true

    # Add current account tracking (which account the session is viewing)
    add_reference :sessions, :current_account, null: true, foreign_key: { to_table: :accounts }

    # Remove user reference
    remove_reference :sessions, :user, foreign_key: true, index: true
  end
end
