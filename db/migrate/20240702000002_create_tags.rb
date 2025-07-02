# frozen_string_literal: true

class CreateTags < ActiveRecord::Migration[8.0]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :color, default: "#6b7280"
      t.integer :posts_count, default: 0, null: false
      t.references :organization, null: false, foreign_key: true

      t.timestamps
    end

    add_index :tags, [:organization_id, :name], unique: true
    add_index :tags, :posts_count
  end
end