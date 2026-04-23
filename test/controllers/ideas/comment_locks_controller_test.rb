# frozen_string_literal: true

require "test_helper"

class Ideas::CommentLocksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @idea = ideas(:one)
  end

  test "admin can lock discussion" do
    sign_in_as users(:admin)

    post idea_comment_lock_url(@idea)

    assert_response :redirect
    assert_redirected_to idea_url(@idea)
    assert_equal I18n.t("ideas.comment_locks.create.locked"), flash[:notice]

    assert_predicate @idea.reload, :comments_locked?
  end

  test "admin can unlock discussion" do
    @idea.update!(comments_locked: true)
    sign_in_as users(:admin)

    delete idea_comment_lock_url(@idea)

    assert_response :redirect
    assert_redirected_to idea_url(@idea)
    assert_equal I18n.t("ideas.comment_locks.destroy.unlocked"), flash[:notice]

    assert_not @idea.reload.comments_locked?
  end

  test "owner can lock discussion" do
    sign_in_as users(:shane)

    post idea_comment_lock_url(@idea)

    assert_response :redirect
    assert_predicate @idea.reload, :comments_locked?
  end

  test "regular member cannot lock discussion" do
    sign_in_as users(:jane)

    post idea_comment_lock_url(@idea)

    assert_response :forbidden
    assert_not @idea.reload.comments_locked?
  end

  test "unauthenticated user cannot lock discussion" do
    post idea_comment_lock_url(@idea)

    assert_response :redirect
    assert_not @idea.reload.comments_locked?
  end
end
