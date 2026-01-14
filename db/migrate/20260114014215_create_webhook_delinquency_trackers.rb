# frozen_string_literal: true

class CreateWebhookDelinquencyTrackers < ActiveRecord::Migration[8.2]
  def change
    create_table :webhook_delinquency_trackers do |t|
      t.references :account, null: false, foreign_key: true
      t.references :webhook, null: false, foreign_key: true
      t.integer :consecutive_failures_count, default: 0
      t.datetime :first_failure_at

      t.timestamps
    end
  end
end
