# frozen_string_literal: true

class PopulateExternalAccountIds < ActiveRecord::Migration[8.2]
  def up
    # Find max existing external_account_id to start sequence after it
    max_id = Account.maximum(:external_account_id) || 0
    next_id = [ max_id + 1, 1_000_000 ].max # Ensure at least 7 digits

    Account.where(external_account_id: nil).find_each do |account|
      account.update_column(:external_account_id, next_id)
      next_id += 1
    end

    change_column_null :accounts, :external_account_id, false
  end

  def down
    change_column_null :accounts, :external_account_id, true
  end
end
