# frozen_string_literal: true

class AddAccountToNotifications < ActiveRecord::Migration[8.2]
  def change
    add_reference :notifications, :account, null: false, foreign_key: true
  end
end
