# frozen_string_literal: true

class CreateBoards < ActiveRecord::Migration[8.0]
  def change
    create_table :boards do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
  end
end
