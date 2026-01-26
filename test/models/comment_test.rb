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

  test "should not allow replies to replies (max 1 level nesting)" do
    reply = comments(:reply_one)

    nested_reply = Comment.new(body: "Nested reply", idea: reply.idea, parent: reply, creator: users(:shane))

    assert_not nested_reply.valid?
    assert_includes nested_reply.errors[:parent_id], "you can only reply to comments, not to other replies"
  end

  test "should allow reply to top-level comment" do
    top_level_comment = comments(:one)

    reply = Comment.new(body: "Valid reply", idea: top_level_comment.idea, parent: top_level_comment, creator: users(:shane))

    assert_predicate reply, :valid?
  end

  test "creates event when regular user creates comment" do
    assert_difference "Event.count", 1 do
      Comment.create!(body: "User comment", idea: ideas(:one), creator: users(:shane))
    end
  end

  test "does not create event when system user creates comment" do
    assert_no_difference "Event.count" do
      Comment.create!(body: "System comment", idea: ideas(:one), creator: users(:system))
    end
  end

  test "auto-watches idea when user comments" do
    idea = ideas(:two)
    user = users(:shane)

    assert_not idea.watched_by?(user)

    Comment.create!(body: "Great idea!", idea: idea, creator: user)

    assert idea.reload.watched_by?(user)
  end

  test "auto-watch is idempotent for existing watchers" do
    idea = ideas(:one)
    user = users(:shane)

    assert idea.watched_by?(user)

    assert_no_difference "Watch.count" do
      Comment.create!(body: "Another comment", idea: idea, creator: user)
    end

    assert idea.watched_by?(user)
  end
end
