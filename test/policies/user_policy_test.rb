# frozen_string_literal: true

require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  setup do
    @user_account = account_users(:feedback_regular_user_one)
    @user = @user_account.user
    @admin_account = account_users(:feedback_admin)
    @another_user_account = account_users(:feedback_regular_user_invited)
  end

  test "user show viewable by all" do
    assert_predicate UserPolicy.new(nil, @user), :show?
  end

  test "user destroy not avaiable by non logged in users" do
    assert_not_predicate UserPolicy.new(nil, @user), :destroy?
  end

  test "user destroy not avaiable by other users" do
    assert_not_predicate UserPolicy.new(@another_user_account, @user), :destroy?
  end

  test "user destroy available by user owner" do
    assert_predicate UserPolicy.new(@user_account, @user), :destroy?
  end

  test "user destroy available by admin" do
    assert_predicate UserPolicy.new(@admin_account, @user), :destroy?
  end
end
