# frozen_string_literal: true

class CreateChangelogIdeas < ActiveRecord::Migration[8.2]
  def change
    create_table :changelog_ideas do |t|
      t.bigint :account_id, null: false
      t.bigint :changelog_id, null: false
      t.bigint :idea_id, null: false
      t.timestamps

      t.index [ :account_id ]
      t.index :idea_id
      t.index [ :changelog_id, :idea_id ], unique: true
    end
  end
end
