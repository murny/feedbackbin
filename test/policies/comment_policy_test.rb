# frozen_string_literal: true

require "test_helper"

class CommentPolicyTest < ActiveSupport::TestCase
  setup do
    # comment one is owned by user one (whos not an admin)
    @comment = comments(:one)
    @user_membership = memberships(:feedback_regular_user_one)
    @admin_membership = memberships(:feedback_admin)
    @another_user_membership = memberships(:feedback_regular_user_invited)
  end

  test "comment show viewable by all" do
    assert_predicate CommentPolicy.new(nil, @comment), :show?
  end

  test "comment create available by logged in users" do
    assert_not_predicate CommentPolicy.new(nil, @comment), :create?
    assert_predicate CommentPolicy.new(@user_membership, @comment), :create?
  end

  test "comment edit available by comment owner or admin" do
    assert_not_predicate CommentPolicy.new(nil, @comment), :edit?
    assert_not_predicate CommentPolicy.new(@another_user_membership, @comment), :edit?
    assert_predicate CommentPolicy.new(@user_membership, @comment), :edit?
    assert_predicate CommentPolicy.new(@admin_membership, @comment), :edit?
  end

  test "comment update available by comment owner or admin" do
    assert_not_predicate CommentPolicy.new(nil, @comment), :update?
    assert_not_predicate CommentPolicy.new(@another_user_membership, @comment), :update?
    assert_predicate CommentPolicy.new(@user_membership, @comment), :update?
    assert_predicate CommentPolicy.new(@admin_membership, @comment), :update?
  end

  test "comment destroy available by comment owner or admin" do
    assert_not_predicate CommentPolicy.new(nil, @comment), :destroy?
    assert_not_predicate CommentPolicy.new(@another_user_membership, @comment), :destroy?
    assert_predicate CommentPolicy.new(@user_membership, @comment), :destroy?
    assert_predicate CommentPolicy.new(@admin_membership, @comment), :destroy?
  end
end
