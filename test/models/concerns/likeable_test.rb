# frozen_string_literal: true

require "test_helper"

class LikeableTest < ActiveSupport::TestCase
  # This test is using the Comment model as the test subject for testing the Likeable concern

  setup do
    @user = users(:one)
    @comment = comments(:one)
  end

  test "liked_by? returns true when user has liked" do
    @comment.like(@user)

    assert @comment.liked_by?(@user)
  end

  test "liked_by? returns false when user has not liked" do
    assert_not @comment.liked_by?(@user)
  end

  test "like creates a new like for the user" do
    assert_difference -> { @comment.likes.count }, 1 do
      assert_difference -> { @comment.voters.count }, 1 do
        @comment.like(@user)
      end
    end

    assert @comment.liked_by?(@user)
  end

  test "like does not create duplicate likes for the same user" do
    @comment.like(@user)

    assert_no_difference -> { @comment.likes.count }, 1 do
      assert_no_difference -> { @comment.voters.count }, 1 do
        @comment.like(@user)
      end
    end

    assert_equal 1, @comment.likes.where(voter: @user).count
  end

  test "unlike removes all likes for the user" do
    @comment.like(@user)

    assert_difference -> { @comment.likes.count }, -1 do
      @comment.unlike(@user)
    end

    assert_not @comment.liked_by?(@user)
  end

  test "unlike does nothing if user has not liked the comment" do
    assert_no_difference -> { @comment.likes.count } do
      @comment.unlike(@user)
    end
  end
end
