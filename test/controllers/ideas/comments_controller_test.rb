# frozen_string_literal: true

require "test_helper"

class Ideas::CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:jane)
    @idea = ideas(:one)
    @comment = comments(:one)
  end

  test "should show comment" do
    get idea_comment_url(@idea, @comment)

    assert_response :success
  end

  test "should edit comment" do
    sign_in_as @user

    get edit_idea_comment_url(@idea, @comment)

    assert_response :success
  end

  test "should create comment if authenticated" do
    sign_in_as @user

    assert_difference "Comment.count" do
      post idea_comments_url(@idea), params: { comment: { body: "Hello, world!" } }
    end

    assert_response :redirect
    assert_redirected_to idea_url(@idea)
    assert_equal I18n.t("ideas.comments.create.successfully_created"), flash[:notice]

    assert_equal "Hello, world!", Comment.last.body.to_plain_text
    assert_equal @user, Comment.last.creator
  end

  test "should not create comment if not authenticated" do
    assert_no_difference "Comment.count" do
      post idea_comments_url(@idea), params: { comment: { body: "Hello, world!" } }
    end

    assert_response :redirect
    assert_redirected_to sign_in_url
  end

  test "should update comment if authenticated" do
    sign_in_as @user

    patch idea_comment_url(@idea, @comment), params: { comment: { body: "This is a new body" } }

    assert_response :redirect
    assert_redirected_to idea_comment_url(@idea, @comment)
    assert_equal I18n.t("ideas.comments.update.successfully_updated"), flash[:notice]

    @comment.reload

    assert_equal "This is a new body", @comment.body.to_plain_text
  end

  test "should not update comment if not authorized" do
    sign_in_as users(:john)

    patch idea_comment_url(@idea, @comment), params: { comment: { body: "Unauthorized update" } }

    assert_response :forbidden

    @comment.reload

    assert_not_equal "Unauthorized update", @comment.body.to_plain_text
  end

  test "should destroy comment" do
    sign_in_as @user

    assert_difference "Comment.count", -1 do
      delete idea_comment_url(@idea, @comment)
    end

    assert_response :redirect
    assert_redirected_to idea_url(@idea)
    assert_equal I18n.t("ideas.comments.destroy.successfully_destroyed"), flash[:notice]
  end

  test "should not destroy comment if not authorized" do
    sign_in_as users(:john)

    assert_no_difference "Comment.count" do
      delete idea_comment_url(@idea, @comment)
    end

    assert_response :forbidden
  end
end
