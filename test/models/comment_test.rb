# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    @comment = comments(:one)
  end

  test "valid comment" do
    assert_predicate @comment, :valid?
  end

  test "invalid without body" do
    @comment.body = nil

    assert_not @comment.valid?
    assert_equal "can't be blank", @comment.errors[:body].first
  end

  test "invalid without idea" do
    @comment.idea = nil

    assert_not @comment.valid?
    assert_equal "must exist", @comment.errors[:idea].first
  end

  test "invalid without creator" do
    # Stub the default current user to nil so we can test the validation
    Current.stubs(:user).returns(nil)
    @comment.creator = nil

    assert_not @comment.valid?
    assert_equal "must exist", @comment.errors[:creator].first
  end

  test "should be able to create a reply to a comment" do
    @reply = Comment.create(body: "Hello, world!", idea: @comment.idea, parent: @comment, creator: users(:shane))

    assert_predicate @reply, :valid?

    assert_equal @comment, @reply.parent
    assert_equal @comment.idea, @reply.idea
    assert_equal 1, @comment.replies.count
    assert_equal @reply, @comment.replies.first
  end
end
