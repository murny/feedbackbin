# frozen_string_literal: true

require "test_helper"

class CommentPolicyTest < ActiveSupport::TestCase
  setup do
    # comment one is owned by user one (who is not an admin)
    @comment = comments(:one)
    @comment_owner = users(:jane)   # regular user (owner of comment one)
    @admin_user = users(:shane)      # admin user
    @regular_user = users(:john)    # regular member user
  end

  test "comment show viewable by all" do
    assert_predicate CommentPolicy.new(nil, @comment), :show?
  end

  test "comment create available by logged in users" do
    assert_not_predicate CommentPolicy.new(nil, @comment), :create?
    assert_predicate CommentPolicy.new(@regular_user, @comment), :create?
  end

  test "comment edit available by comment owner or admin" do
    assert_not_predicate CommentPolicy.new(nil, @comment), :edit?
    assert_not_predicate CommentPolicy.new(@regular_user, @comment), :edit?
    assert_predicate CommentPolicy.new(@comment_owner, @comment), :edit?
    assert_predicate CommentPolicy.new(@admin_user, @comment), :edit?
  end

  test "comment update available by comment owner or admin" do
    assert_not_predicate CommentPolicy.new(nil, @comment), :update?
    assert_not_predicate CommentPolicy.new(@regular_user, @comment), :update?
    assert_predicate CommentPolicy.new(@comment_owner, @comment), :update?
    assert_predicate CommentPolicy.new(@admin_user, @comment), :update?
  end

  test "comment destroy available by comment owner or admin" do
    assert_not_predicate CommentPolicy.new(nil, @comment), :destroy?
    assert_not_predicate CommentPolicy.new(@regular_user, @comment), :destroy?
    assert_predicate CommentPolicy.new(@comment_owner, @comment), :destroy?
    assert_predicate CommentPolicy.new(@admin_user, @comment), :destroy?
  end
end
