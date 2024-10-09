# frozen_string_literal: true

require "test_helper"

class BoardTest < ActiveSupport::TestCase
  setup do
    @board = boards(:one)
  end

  test "valid board" do
    assert_predicate @board, :valid?
  end

  test "invalid without name" do
    @board.name = nil

    assert_not @board.valid?
    assert_equal "can't be blank", @board.errors[:name].first
  end
end
