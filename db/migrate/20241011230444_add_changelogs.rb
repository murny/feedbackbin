# frozen_string_literal: true

class AddChangelogs < ActiveRecord::Migration[8.0]
  def change
    create_table :changelogs do |t|
      t.string :title, null: false
      t.string :kind, null: false
      t.datetime :published_at

      t.timestamps
    end
  end
end
