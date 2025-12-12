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

  test "invalid without a author" do
    # Stub the default current user to nil so we can test the validation
    Current.stub(:user, nil) do
      @idea.author = nil

      assert_not @idea.valid?
      assert_equal "must exist", @idea.errors[:author].first
    end
  end

  test "invalid without a board" do
    @idea.board = nil

    assert_not @idea.valid?
    assert_equal "must exist", @idea.errors[:board].first
  end

  test "invalid without a status" do
    # Stub the default status to nil so we can test the validation
    Status.stub(:default, nil) do
      @idea.status = nil

      assert_not @idea.valid?
      assert_equal "must exist", @idea.errors[:status].first
    end
  end

  test "new idea gets default status automatically" do
    idea = Idea.create(
      title: "Test",
      author: users(:shane),
      board: boards(:one)
    )

    # Default should be set automatically from account's default
    assert_not_nil idea.status
    assert_equal Status.default, idea.status
    assert_equal "Open", idea.status.name
  end
end
