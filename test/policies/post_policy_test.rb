# frozen_string_literal: true

require "test_helper"

class PostPolicyTest < ActiveSupport::TestCase
  setup do
    # post two is owned by user one (whos not an admin)
    @post = posts(:two)
    @user_membership = memberships(:feedbackbin_regular_user_one)
    @admin_membership = memberships(:feedbackbin_admin)
    @another_user_membership = memberships(:feedbackbin_regular_user_two)
  end

  test "post index viewable by all" do
    assert_predicate PostPolicy.new(nil, @post), :index?
  end

  test "post show viewable by all" do
    assert_predicate PostPolicy.new(nil, @post), :show?
  end

  test "post create available by logged in users" do
    assert_not_predicate PostPolicy.new(nil, @post), :create?
    assert_predicate PostPolicy.new(@user_membership, @post), :create?
  end

  test "post new available by logged in users" do
    assert_not_predicate PostPolicy.new(nil, @post), :new?
    assert_predicate PostPolicy.new(@user_membership, @post), :new?
  end

  test "post edit available by post owner or admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :edit?
    assert_not_predicate PostPolicy.new(@another_user_membership, @post), :edit?
    assert_predicate PostPolicy.new(@user_membership, @post), :edit?
    assert_predicate PostPolicy.new(@admin_membership, @post), :edit?
  end

  test "post update available by post owner or admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :update?
    assert_not_predicate PostPolicy.new(@another_user_membership, @post), :update?
    assert_predicate PostPolicy.new(@user_membership, @post), :update?
    assert_predicate PostPolicy.new(@admin_membership, @post), :update?
  end

  test "post destroy available by post owner or admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :destroy?
    assert_not_predicate PostPolicy.new(@another_user_membership, @post), :destroy?
    assert_predicate PostPolicy.new(@user_membership, @post), :destroy?
    assert_predicate PostPolicy.new(@admin_membership, @post), :destroy?
  end

  test "post pin only available to admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :pin?
    assert_not_predicate PostPolicy.new(@user_membership, @post), :pin?
    assert_not_predicate PostPolicy.new(@another_user_membership, @post), :pin?
    assert_predicate PostPolicy.new(@admin_membership, @post), :pin?
  end

  test "post unpin only available to admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :unpin?
    assert_not_predicate PostPolicy.new(@user_membership, @post), :unpin?
    assert_not_predicate PostPolicy.new(@another_user_membership, @post), :unpin?
    assert_predicate PostPolicy.new(@admin_membership, @post), :unpin?
  end
end
