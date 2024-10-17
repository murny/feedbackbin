# frozen_string_literal: true

class CreateSignInTokensMigration < ActiveRecord::Migration[8.0]
  def change
    create_table :sign_in_tokens do |t|
      t.references :user, null: false, foreign_key: true
    end
  end
end
