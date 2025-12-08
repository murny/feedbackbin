# frozen_string_literal: true

require "test_helper"

class Comment::ThreadableTest < ActiveSupport::TestCase
  setup do
    @comment = comments(:one)
    @post = posts(:one)
    @user = users(:shane)
    Current.organization = organizations(:feedbackbin)
  end

  test "belongs to parent comment optionally" do
    assert_nil @comment.parent
    assert_predicate @comment.parent, :blank?
  end

  test "has many replies" do
    reply = Comment.create!(
      body: "Reply",
      creator: @user,
      post: @post,
      parent: @comment
    )

    assert_includes @comment.replies, reply
    assert_equal 1, @comment.replies.count
  end

  test "top_level scope returns comments without parent" do
    top_level_comment = @comment
    reply = Comment.create!(
      body: "Reply",
      creator: @user,
      post: @post,
      parent: @comment
    )

    top_level_comments = Comment.top_level

    assert_includes top_level_comments, top_level_comment
    assert_not_includes top_level_comments, reply
  end

  test "replies_to scope returns replies to a specific comment" do
    reply = Comment.create!(
      body: "Reply",
      creator: @user,
      post: @post,
      parent: @comment
    )

    replies = Comment.replies_to(@comment)

    assert_includes replies, reply
    assert_equal 1, replies.count
  end

  test "top_level? returns true for comments without parent" do
    assert_predicate @comment, :top_level?
  end

  test "top_level? returns false for reply comments" do
    reply = Comment.create!(
      body: "Reply",
      creator: @user,
      post: @post,
      parent: @comment
    )

    assert_not reply.top_level?
  end

  test "reply? returns false for top level comments" do
    assert_not @comment.reply?
  end

  test "reply? returns true for reply comments" do
    reply = Comment.create!(
      body: "Reply",
      creator: @user,
      post: @post,
      parent: @comment
    )

    assert_predicate reply, :reply?
  end

  test "has_replies? returns false when comment has no replies" do
    assert_not @comment.has_replies?
  end

  test "has_replies? returns true when comment has replies" do
    Comment.create!(
      body: "Reply",
      creator: @user,
      post: @post,
      parent: @comment
    )

    assert_predicate @comment, :has_replies?
  end

  test "validates single level nesting - cannot reply to a reply" do
    reply = Comment.create!(
      body: "Reply",
      creator: @user,
      post: @post,
      parent: @comment
    )

    nested_reply = Comment.new(
      body: "Nested reply",
      creator: @user,
      post: @post,
      parent: reply
    )

    assert_not nested_reply.valid?
    assert_includes nested_reply.errors[:parent_id], "cannot be nested more than one level"
  end

  test "allows reply to top level comment" do
    reply = Comment.new(
      body: "Reply",
      creator: @user,
      post: @post,
      parent: @comment
    )

    assert_predicate reply, :valid?
  end

  test "destroying parent destroys replies" do
    reply = Comment.create!(
      body: "Reply",
      creator: @user,
      post: @post,
      parent: @comment
    )

    assert_difference -> { Comment.count }, -2 do
      @comment.destroy!
    end

    assert_not Comment.exists?(reply.id)
  end
end
