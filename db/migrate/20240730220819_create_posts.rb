# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :title, null: false
      t.text :description

      t.timestamps
    end
  end
end
