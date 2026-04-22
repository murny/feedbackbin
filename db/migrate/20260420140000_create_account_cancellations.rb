# frozen_string_literal: true

class CreateAccountCancellations < ActiveRecord::Migration[8.2]
  def change
    create_table :account_cancellations do |t|
      t.bigint :account_id, null: false
      t.bigint :initiated_by_id, null: false

      t.timestamps

      t.index [ :account_id ], unique: true
      t.index [ :initiated_by_id ]
    end
  end
end
