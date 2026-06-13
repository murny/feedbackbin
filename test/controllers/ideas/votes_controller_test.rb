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

  test "turbo_stream response includes aria-pressed=true after a successful vote" do
    sign_in_as @user

    patch idea_vote_url(@idea), headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_match(/aria-pressed="true"/, response.body)
  end

  test "turbo_stream update sets flash alert and 422 status when vote raises RecordInvalid" do
    sign_in_as @user
    Idea.any_instance.stubs(:vote).raises(ActiveRecord::RecordInvalid.new(@idea))

    assert_no_difference -> { @idea.votes.count } do
      patch idea_vote_url(@idea), headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :unprocessable_entity
    assert_equal I18n.t("ideas.votes.update.error"), flash[:alert]
  end
end
