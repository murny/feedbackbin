# frozen_string_literal: true

class AddStatusRefToPosts < ActiveRecord::Migration[8.0]
  def change
    add_reference :posts, :status, foreign_key: true
  end
end
