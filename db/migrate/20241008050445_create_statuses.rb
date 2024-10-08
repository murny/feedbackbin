# frozen_string_literal: true

class CreateStatuses < ActiveRecord::Migration[8.0]
  def change
    create_table :statuses do |t|
      t.string :name, null: false
      t.string :color, null: false
      t.integer :position, null: false

      t.timestamps
    end
  end
end
