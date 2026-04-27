# frozen_string_literal: true

require "test_helper"

class BoardTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
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
    duplicate = Board.new(name: @board.name, color: "#3b82f6", creator: users(:shane))

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
    Board.create!(name: "Zebra", color: "#3b82f6", creator: users(:shane))
    Board.create!(name: "Alpha", color: "#10b981", creator: users(:shane))

    ordered = Board.ordered

    assert_equal "Alpha", ordered.first.name
    assert_equal "Zebra", ordered.last.name
  end

  # Access associations
  test "has many accesses" do
    assert_includes @board.accesses, accesses(:shane_feature_requests)
  end

  test "has many users through accesses" do
    assert_includes @board.users, users(:shane)
  end

  # all_access scope
  test "all_access scope returns boards with all_access true" do
    assert_includes Board.all_access, boards(:one)

    boards(:one).update!(all_access: false)

    assert_not_includes Board.all_access, boards(:one)
  end

  # accessible_to?
  test "accessible_to? is true for all_access board" do
    assert_predicate @board, :all_access?
    assert @board.accessible_to?(users(:admin))
  end

  test "accessible_to? is true when user has access row" do
    @board.update!(all_access: false)

    assert @board.accessible_to?(users(:shane))
  end

  test "accessible_to? is false when user has no access row and board is not all_access" do
    @board.update!(all_access: false)

    assert_not @board.accessible_to?(users(:admin))
  end

  # access_for
  test "access_for returns access row for user" do
    assert_equal accesses(:shane_feature_requests), @board.access_for(users(:shane))
  end

  test "access_for returns nil when user has no access" do
    assert_nil @board.access_for(users(:admin))
  end

  # accessed_by
  test "accessed_by creates access and touches accessed_at" do
    access = @board.accessed_by(users(:admin))

    assert_predicate access, :persisted?
    assert_not_nil access.accessed_at
  end

  test "accessed_by updates accessed_at for existing access" do
    original_access = accesses(:shane_feature_requests)
    original_accessed_at = original_access.accessed_at

    travel 1.hour do
      @board.accessed_by(users(:shane))
      original_access.reload

      assert_operator original_access.accessed_at, :>, original_accessed_at
    end
  end

  test "accessed_by returns nil and does not create access when user is not authorized" do
    @board.update!(all_access: false)

    assert_nil @board.accessed_by(users(:admin))
    assert_nil @board.access_for(users(:admin))
  end

  # Creator access callback
  test "creating a board grants creator watching access" do
    board = Board.create!(name: "New Board", color: "#10b981", creator: users(:shane))

    access = board.accesses.find_by(user: users(:shane))

    assert_not_nil access
    assert_predicate access, :involvement_watching?
  end

  # Dependent restrict_with_error
  test "cannot delete board with ideas" do
    board = boards(:one)
    # Create an idea with this board
    Idea.create!(
      title: "Test Idea",
      board: board,
      creator: users(:jane),
      status: statuses(:planned)
    )

    board.destroy

    assert Board.exists?(board.id)
    assert_equal "Cannot delete record because dependent ideas exist", board.errors[:base].first
  end
end
