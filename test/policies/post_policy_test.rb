# frozen_string_literal: true

require "test_helper"

class PostPolicyTest < ActiveSupport::TestCase
  setup do
    # post two is owned by user one (whos not an admin)
    @post = posts(:two)
    @user_account = account_users(:feedback_regular_user_one)
    @admin_account = account_users(:feedback_admin)
    @another_user_account = account_users(:feedback_regular_user_invited)
  end

  test "post index viewable by all" do
    assert_predicate PostPolicy.new(nil, @post), :index?
  end

  test "post show viewable by all" do
    assert_predicate PostPolicy.new(nil, @post), :show?
  end

  test "post create available by logged in users" do
    assert_not_predicate PostPolicy.new(nil, @post), :create?
    assert_predicate PostPolicy.new(@user_account, @post), :create?
  end

  test "post new available by logged in users" do
    assert_not_predicate PostPolicy.new(nil, @post), :new?
    assert_predicate PostPolicy.new(@user_account, @post), :new?
  end

  test "post edit available by post owner or admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :edit?
    assert_not_predicate PostPolicy.new(@another_user_account, @post), :edit?
    assert_predicate PostPolicy.new(@user_account, @post), :edit?
    assert_predicate PostPolicy.new(@admin_account, @post), :edit?
  end

  test "post update available by post owner or admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :update?
    assert_not_predicate PostPolicy.new(@another_user_account, @post), :update?
    assert_predicate PostPolicy.new(@user_account, @post), :update?
    assert_predicate PostPolicy.new(@admin_account, @post), :update?
  end

  test "post destroy available by post owner or admin" do
    assert_not_predicate PostPolicy.new(nil, @post), :destroy?
    assert_not_predicate PostPolicy.new(@another_user_account, @post), :destroy?
    assert_predicate PostPolicy.new(@user_account, @post), :destroy?
    assert_predicate PostPolicy.new(@admin_account, @post), :destroy?
  end
end
