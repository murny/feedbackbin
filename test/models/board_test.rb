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

  test "invalid if name taken" do
    duplicate = Board.new(name: @board.name, color: "#3b82f6")

    assert_not duplicate.valid?
    assert_equal "has already been taken", duplicate.errors[:name].first
  end

  # Color validations
  test "invalid without color" do
    @board.color = nil

    assert_not @board.valid?
    assert_includes @board.errors[:color], "can't be blank"
  end

  test "invalid with malformed color" do
    @board.color = "blue"

    assert_not @board.valid?
    assert_includes @board.errors[:color], "must be a valid hex color code"
  end

  test "invalid with short hex color" do
    @board.color = "#fff"

    assert_not @board.valid?
    assert_includes @board.errors[:color], "must be a valid hex color code"
  end

  test "invalid with description over 500 characters" do
    @board.description = "a" * 501

    assert_not @board.valid?
    assert_includes @board.errors[:description], "is too long (maximum is 500 characters)"
  end

  # Scopes
  test "ordered scope returns boards alphabetically" do
    Board.create!(name: "Zebra", color: "#3b82f6")
    Board.create!(name: "Alpha", color: "#10b981")

    ordered = Board.ordered

    assert_equal "Alpha", ordered.first.name
    assert_equal "Zebra", ordered.last.name
  end

  # Dependent restrict_with_error
  test "cannot delete board with ideas" do
    board = boards(:one)
    # Create an idea with this board
    Idea.create!(
      title: "Test Idea",
      board: board,
      author: users(:one),
      status: statuses(:planned)
    )

    board.destroy

    assert Board.exists?(board.id)
    assert_equal "Cannot delete record because dependent ideas exist", board.errors[:base].first
  end
end
