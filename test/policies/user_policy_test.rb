# frozen_string_literal: true

require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  setup do
    @target_user = users(:jane)      # regular user
    @owner_user = users(:shane)       # owner user
    @admin_user = users(:admin)       # admin user
    @regular_user = users(:john)     # regular member user
  end

  test "user show viewable by all" do
    assert_predicate UserPolicy.new(nil, @target_user), :show?
  end

  test "user destroy not available by non logged in users" do
    assert_not_predicate UserPolicy.new(nil, @target_user), :destroy?
  end

  test "user destroy not available by other users" do
    assert_not_predicate UserPolicy.new(@regular_user, @target_user), :destroy?
  end

  test "user destroy available by user owner" do
    assert_predicate UserPolicy.new(@target_user, @target_user), :destroy?
  end

  test "user destroy available by admin" do
    assert_predicate UserPolicy.new(@admin_user, @target_user), :destroy?
  end

  test "account owner cannot be destroyed" do
    assert_not_predicate UserPolicy.new(@admin_user, @owner_user), :destroy?
  end
end
