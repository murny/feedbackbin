# frozen_string_literal: true

class AddBoardRefToPosts < ActiveRecord::Migration[8.0]
  def change
    default_board_id = Class.new(ApplicationRecord)
      .tap { |c| c.table_name = :boards }
      .find_or_create_by(name: "Feature Requests")
      .id
    add_reference :posts, :board, null: false, foreign_key: true, default: default_board_id
    change_column_default :posts, :board_id, from: default_board_id, to: nil
  end
end
