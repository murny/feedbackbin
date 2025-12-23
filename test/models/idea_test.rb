# frozen_string_literal: true

require "test_helper"

class IdeaTest < ActiveSupport::TestCase
  def setup
    @idea = ideas(:one)
  end

  test "valid idea" do
    assert_predicate @idea, :valid?
  end

  test "invalid without a title" do
    @idea.title = nil

    assert_not @idea.valid?
    assert_equal "can't be blank", @idea.errors[:title].first
  end

  test "invalid without a creator" do
    # Stub the default current user to nil so we can test the validation
    Current.stubs(:user).returns(nil)
    @idea.creator = nil

    assert_not @idea.valid?
    assert_equal "must exist", @idea.errors[:creator].first
  end

  test "invalid without a board" do
    @idea.board = nil

    assert_not @idea.valid?
    assert_equal "must exist", @idea.errors[:board].first
  end

  test "valid without a status (nil means Open)" do
    @idea.status = nil

    assert_predicate @idea, :valid?
    assert_predicate @idea, :open?
    assert_equal "Open", @idea.status_name
  end

  test "new idea without status is Open by default" do
    idea = Idea.create!(
      title: "Test",
      creator: users(:shane),
      board: boards(:one)
    )

    # nil status means "Open"
    assert_nil idea.status
    assert_predicate idea, :open?
    assert_equal "Open", idea.status_name
    assert_equal "#3b82f6", idea.status_color
  end

  test "idea with status uses that status" do
    idea = Idea.create!(
      title: "Test",
      creator: users(:shane),
      board: boards(:one),
      status: statuses(:planned)
    )

    assert_not_nil idea.status
    assert_not idea.open?
    assert_equal "Planned", idea.status_name
    assert_equal statuses(:planned).color, idea.status_color
  end
end
