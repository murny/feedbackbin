# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
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

  test "invalid without post" do
    @comment.post = nil

    assert_not @comment.valid?
    assert_equal "must exist", @comment.errors[:post].first
  end

  test "invalid without creator" do
    @comment.creator = nil

    assert_not @comment.valid?
    assert_equal "must exist", @comment.errors[:creator].first
  end

  test "should be able to create a reply to a comment" do
    @reply = Comment.create(body: "Hello, world!", post: @comment.post, parent: @comment, creator: users(:shane), organization: @comment.organization)

    assert_predicate @reply, :valid?

    assert_equal @comment, @reply.parent
    assert_equal @comment.post, @reply.post
    assert_equal 1, @comment.replies.count
    assert_equal @reply, @comment.replies.first
  end

  test "invalid without an organization" do
    @comment.organization = nil

    assert_not @comment.valid?
    assert_equal "must exist", @comment.errors[:organization].first
  end
end
