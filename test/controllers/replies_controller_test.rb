# frozen_string_literal: true

require "test_helper"

class RepliesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @comment = comments(:one)
    @reply = comments(:reply_one)
  end

  test "should show reply" do
    get reply_url(@reply)

    assert_response :success
  end

  test "should edit reply" do
    sign_in @user

    get edit_reply_url(@reply)

    assert_response :success
  end

  test "should create reply if authenticated" do
    sign_in @user

    assert_difference "Comment.count" do
      post replies_url, params: {reply: {parent_id: @comment.id, post_id: @comment.post.id, body: "Hello, world!"}}
    end

    assert_response :redirect
    assert_redirected_to comment_url(@comment)

    assert_equal "Hello, world!", Comment.last.body.to_plain_text
    assert_equal @user, Comment.last.creator
  end

  test "should not create reply if not authenticated" do
    assert_no_difference "Comment.count" do
      post replies_url, params: {reply: {parent_id: @comment.id, post_id: @comment.post.id, body: "Hello, world!"}}
    end

    assert_response :redirect
    assert_redirected_to sign_in_url
  end

  test "should update reply if authenticated" do
    sign_in @user

    patch reply_url(@reply), params: {reply: {body: "This is a new body"}}

    assert_response :redirect
    assert_redirected_to reply_url(@reply)

    @reply.reload

    assert_equal "This is a new body", @reply.body.to_plain_text
  end

  test "should destroy reply" do
    sign_in @user

    assert_difference "Comment.count", -1 do
      delete reply_url(@reply)
    end

    assert_response :redirect
    assert_redirected_to post_url(@reply.post)
  end
end
