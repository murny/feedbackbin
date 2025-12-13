# frozen_string_literal: true

class MakeAccountsDefaultStatusOptional < ActiveRecord::Migration[8.2]
  def change
    change_column_null :accounts, :default_status_id, true
  end
end
