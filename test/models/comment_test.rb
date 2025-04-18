# frozen_string_literal: true

require "test_helper"

class CommentTest < ActiveSupport::TestCase
  setup do
    @comment = comments(:one)
  end

  test "valid comment" do
    assert_predicate @comment, :valid?
  end

  test "invalid without body" do
    @comment.body = nil

    assert_not @comment.valid?
    assert_equal "can't be blank", @comment.errors[:body].first
  end

  test "invalid without post" do
    @comment.post = nil

    assert_not @comment.valid?
    assert_equal "must exist", @comment.errors[:post].first
  end

  test "invalid without creator" do
    @comment.creator = nil

    assert_not @comment.valid?
    assert_equal "must exist", @comment.errors[:creator].first
  end

  test "should be able to create a reply to a comment" do
    @reply = Comment.create(body: "Hello, world!", post: @comment.post, parent: @comment, creator: users(:shane), organization: @comment.organization)

    assert_predicate @reply, :valid?

    assert_equal @comment, @reply.parent
    assert_equal @comment.post, @reply.post
    assert_equal 1, @comment.replies.count
    assert_equal @reply, @comment.replies.first
  end

  test "invalid without an organization" do
    @comment.organization = nil

    assert_not @comment.valid?
    assert_equal "must exist", @comment.errors[:organization].first
  end

  # Tests for Likeable concern
  test "liked_by? returns true when user has liked the comment" do
    user = users(:shane)
    organization = organizations(:feedbackbin)
    
    # Set Current.organization for the test
    Current.organization = organization
    
    @comment.like(user)
    assert @comment.liked_by?(user)
  end

  test "liked_by? returns false when user has not liked the comment" do
    user = users(:shane)
    assert_not @comment.liked_by?(user)
  end

  test "like creates a new like for the user" do
    user = users(:shane)
    organization = organizations(:feedbackbin)
    
    # Set Current.organization for the test
    Current.organization = organization
    
    assert_difference -> { @comment.likes.count }, 1 do
      @comment.like(user)
    end
    
    assert @comment.liked_by?(user)
  end

  test "like does not create duplicate likes for the same user" do
    user = users(:shane)
    organization = organizations(:feedbackbin)
    
    # Set Current.organization for the test
    Current.organization = organization
    
    @comment.like(user)
    
    assert_no_difference -> { @comment.likes.count } do
      @comment.like(user)
    end
    
    assert_equal 1, @comment.likes.where(voter: user).count
  end

  test "unlike removes all likes for the user" do
    user = users(:shane)
    organization = organizations(:feedbackbin)
    
    # Set Current.organization for the test
    Current.organization = organization
    
    @comment.like(user)
    
    assert_difference -> { @comment.likes.count }, -1 do
      @comment.unlike(user)
    end
    
    assert_not @comment.liked_by?(user)
  end

  test "unlike does nothing if user has not liked the comment" do
    user = users(:shane)
    
    assert_no_difference -> { @comment.likes.count } do
      @comment.unlike(user)
    end
  end
  
  teardown do
    # Reset Current attributes
    Current.reset
  end
end
