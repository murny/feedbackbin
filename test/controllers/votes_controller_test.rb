# frozen_string_literal: true

require "test_helper"

class VotesControllerTest < ActionDispatch::IntegrationTest
  test "should update voteable" do
    idea = ideas(:one)
    user = users(:jane)

    sign_in_as user

    assert_difference -> { idea.votes.count }, 1 do
      patch vote_url(voteable_type: "Idea", voteable_id: idea.id)

      assert_redirected_to idea, notice: "Idea was successfully liked."
    end

    assert_difference -> { idea.votes.count }, -1 do
      patch vote_url(voteable_type: "Idea", voteable_id: idea.id)

      assert_redirected_to idea, notice: "Idea was successfully unliked."
    end
  end

  test "should not update voteable if voteable is not an approved voteable" do
    board = boards(:one)
    user = users(:jane)

    sign_in_as user

    assert_no_difference -> { Vote.count } do
      patch vote_url(voteable_type: "Board", voteable_id: board.id)

      assert_response :unprocessable_entity
    end
  end
end
