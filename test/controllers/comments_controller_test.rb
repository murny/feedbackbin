# frozen_string_literal: true

require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:jane)
    @idea = ideas(:one)
    @comment = comments(:one)
  end

  test "should show comment" do
    get comment_url(@comment)

    assert_response :success
  end

  test "should edit comment" do
    sign_in_as @user

    get edit_comment_url(@comment)

    assert_response :success
  end

  test "should create comment if authenticated" do
    sign_in_as @user

    assert_difference "Comment.count" do
      post comments_url, params: { comment: { idea_id: @idea.id, body: "Hello, world!" } }
    end

    assert_response :redirect
    assert_redirected_to idea_url(@idea), notice: "Comment was successfully created."

    assert_equal "Hello, world!", Comment.last.body.to_plain_text
    assert_equal @user, Comment.last.creator
  end

  test "should not create comment if not authenticated" do
    assert_no_difference "Comment.count" do
      post comments_url, params: { comment: { idea_id: @idea.id, body: "Hello, world!" } }
    end

    assert_response :redirect
    assert_redirected_to sign_in_url
  end

  test "should update comment if authenticated" do
    sign_in_as @user

    patch comment_url(@comment), params: { comment: { body: "This is a new body" } }

    assert_response :redirect
    assert_redirected_to comment_url(@comment), notice: "Comment was successfully updated."

    @comment.reload

    assert_equal "This is a new body", @comment.body.to_plain_text
  end

  test "should destroy comment" do
    sign_in_as @user

    assert_difference "Comment.count", -1 do
      delete comment_url(@comment)
    end

    assert_response :redirect
    assert_redirected_to idea_url(@comment.idea), notice: "Comment was successfully destroyed."
  end
end
