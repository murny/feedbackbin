# frozen_string_literal: true

require "test_helper"

class VoteableTest < ActiveSupport::TestCase
  # This test is using the Comment model as the test subject for testing the Voteable concern

  setup do
    @user = users(:one)
    @comment = comments(:one)
  end

  test "voted_by? returns true when user has voted" do
    @comment.vote(@user)

    assert @comment.voted_by?(@user)
  end

  test "voted_by? returns false when user has not voted" do
    assert_not @comment.voted_by?(@user)
  end

  test "vote creates a new vote for the user" do
    assert_difference -> { @comment.votes.count }, 1 do
      assert_difference -> { @comment.voters.count }, 1 do
        @comment.vote(@user)
      end
    end

    assert @comment.voted_by?(@user)
  end

  test "vote does not create duplicate votes for the same user" do
    @comment.vote(@user)

    assert_no_difference -> { @comment.votes.count }, 1 do
      assert_no_difference -> { @comment.voters.count }, 1 do
        @comment.vote(@user)
      end
    end

    assert_equal 1, @comment.votes.where(voter: @user).count
  end

  test "unvote removes all votes for the user" do
    @comment.vote(@user)

    assert_difference -> { @comment.votes.count }, -1 do
      @comment.unvote(@user)
    end

    assert_not @comment.voted_by?(@user)
  end

  test "unvote does nothing if user has not voted the comment" do
    assert_no_difference -> { @comment.votes.count } do
      @comment.unvote(@user)
    end
  end
end
