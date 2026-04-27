# frozen_string_literal: true

class AddAllAccessToBoards < ActiveRecord::Migration[8.2]
  def change
    add_column :boards, :all_access, :boolean, default: true, null: false
  end
end
