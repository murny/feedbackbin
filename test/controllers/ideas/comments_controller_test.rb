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

  test "should not create comment on locked idea for regular user" do
    locked_idea = ideas(:locked)
    sign_in_as users(:jane)

    assert_no_difference "Comment.count" do
      post idea_comments_url(locked_idea), params: { comment: { body: "Hello!" } }
    end

    assert_response :redirect
    assert_redirected_to idea_url(locked_idea)
    assert_equal I18n.t("ideas.comments.create.comments_locked"), flash[:alert]
  end

  test "admin can comment on locked idea" do
    locked_idea = ideas(:locked)
    sign_in_as users(:admin)

    assert_difference "Comment.count" do
      post idea_comments_url(locked_idea), params: { comment: { body: "Admin comment on locked idea" } }
    end

    assert_response :redirect
  end

  test "owner can comment on locked idea" do
    locked_idea = ideas(:locked)
    sign_in_as users(:shane)

    assert_difference "Comment.count" do
      post idea_comments_url(locked_idea), params: { comment: { body: "Owner comment on locked idea" } }
    end

    assert_response :redirect
  end

  test "update by author stamps edited_at when body present" do
    sign_in_as @user

    assert_nil @comment.edited_at

    patch idea_comment_url(@idea, @comment), params: { comment: { body: "Edited body" } }

    assert_response :redirect
    @comment.reload

    assert_not_nil @comment.edited_at
    assert_equal "Edited body", @comment.body.to_plain_text
  end

  test "admin can edit any comment and stamps edited_at" do
    sign_in_as users(:admin)

    assert_nil @comment.edited_at
    assert_not_equal users(:admin), @comment.creator

    patch idea_comment_url(@idea, @comment), params: { comment: { body: "Admin-edited body" } }

    assert_response :redirect
    @comment.reload

    assert_not_nil @comment.edited_at
    assert_equal "Admin-edited body", @comment.body.to_plain_text
  end

  test "third party cannot edit comment" do
    sign_in_as users(:john)

    assert_nil @comment.edited_at

    patch idea_comment_url(@idea, @comment), params: { comment: { body: "Forbidden edit" } }

    assert_response :forbidden
    @comment.reload

    assert_nil @comment.edited_at
  end

  test "update without body in params does not stamp edited_at" do
    sign_in_as @user

    assert_nil @comment.edited_at
    original_body = @comment.body.to_plain_text

    patch idea_comment_url(@idea, @comment), params: { comment: { parent_id: nil } }

    @comment.reload

    assert_nil @comment.edited_at
    assert_equal original_body, @comment.body.to_plain_text
  end

  test "admin can create internal comment" do
    sign_in_as users(:admin)

    assert_difference "Comment.count" do
      post idea_comments_url(@idea), params: { comment: { body: "Admin internal note", internal: true } }
    end

    assert_response :redirect
    assert Comment.last.internal
  end

  test "member cannot create internal comment - param stripped" do
    sign_in_as users(:jane)

    assert_difference "Comment.count" do
      post idea_comments_url(@idea), params: { comment: { body: "Sneaky internal attempt", internal: true } }
    end

    assert_response :redirect
    refute Comment.last.internal
  end

  test "admin sees internal comments on idea show" do
    sign_in_as users(:admin)

    get idea_url(@idea)

    assert_response :success
    assert_includes response.body, comments(:internal_one).body.to_plain_text
  end

  test "member does not see internal comments on idea show" do
    sign_in_as users(:jane)

    get idea_url(@idea)

    assert_response :success
    assert_not_includes response.body, comments(:internal_one).body.to_plain_text
  end
end
