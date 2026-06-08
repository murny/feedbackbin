# frozen_string_literal: true

class CreateVisits < ActiveRecord::Migration[8.2]
  def change
    create_table :visits do |t|
      t.references :account, null: false
      t.references :user, null: false
      t.bigint :idea_id, null: false
      t.datetime :visited_at, null: false
      t.timestamps
    end

    add_index :visits, [ :account_id, :user_id, :idea_id ],
              unique: true, name: "idx_visits_uniqueness"
    add_index :visits, [ :user_id, :account_id, :visited_at ]
    add_index :visits, :idea_id
  end
end
