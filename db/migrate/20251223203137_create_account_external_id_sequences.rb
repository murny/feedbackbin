# frozen_string_literal: true

class CreateAccountExternalIdSequences < ActiveRecord::Migration[8.2]
  def change
    create_table :account_external_id_sequences do |t|
      t.bigint :value, null: false, default: 0

      t.timestamps
    end

    add_index :account_external_id_sequences, :value, unique: true
  end
end
