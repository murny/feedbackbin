# frozen_string_literal: true

require "test_helper"

class Ideas::Comments::VotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @idea = ideas(:one)
    @comment = comments(:one)
    @user = users(:jane)
  end

  test "should vote for comment" do
    sign_in_as @user

    assert_difference -> { @comment.votes.count }, 1 do
      patch idea_comment_vote_url(@idea, @comment)

      assert_redirected_to idea_comment_path(@idea, @comment)
    end
  end

  test "should unvote comment" do
    sign_in_as @user
    @comment.vote(@user)

    assert_difference -> { @comment.votes.count }, -1 do
      patch idea_comment_vote_url(@idea, @comment)

      assert_redirected_to idea_comment_path(@idea, @comment)
    end
  end

  test "should not vote if not authenticated" do
    assert_no_difference -> { @comment.votes.count } do
      patch idea_comment_vote_url(@idea, @comment)
    end

    assert_redirected_to sign_in_url
  end
end
