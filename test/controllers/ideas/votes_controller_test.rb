# frozen_string_literal: true

require "test_helper"

class Ideas::VotesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @idea = ideas(:one)
    @user = users(:jane)
  end

  test "should vote for idea" do
    sign_in_as @user

    assert_difference -> { @idea.votes.count }, 1 do
      patch idea_vote_url(@idea)

      assert_redirected_to @idea
      assert_equal I18n.t("ideas.votes.update.successfully_voted"), flash[:notice]
    end
  end

  test "should unvote idea" do
    sign_in_as @user
    @idea.vote(@user)

    assert_difference -> { @idea.votes.count }, -1 do
      patch idea_vote_url(@idea)

      assert_redirected_to @idea
      assert_equal I18n.t("ideas.votes.update.successfully_unvoted"), flash[:notice]
    end
  end

  test "should not vote if not authenticated" do
    assert_no_difference -> { @idea.votes.count } do
      patch idea_vote_url(@idea)
    end

    assert_redirected_to sign_in_url
  end
end
