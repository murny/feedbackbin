# frozen_string_literal: true

require "test_helper"

class MembershipPolicyTest < ActiveSupport::TestCase
  def setup
    @user_membership = memberships(:feedbackbin_regular_user_one)
    @admin_membership = memberships(:feedbackbin_admin)
  end

  test "membership index viewable if logged in" do
    assert_not_predicate MembershipPolicy.new(nil, Membership), :index?

    assert_predicate MembershipPolicy.new(@user_membership, Membership), :index?
    assert_predicate MembershipPolicy.new(@admin_membership, Membership), :index?
  end

  test "membership edit available if admin" do
    assert_not_predicate MembershipPolicy.new(nil, @user_membership), :edit?
    assert_not_predicate MembershipPolicy.new(@user_membership, @user_membership), :edit?

    assert_predicate MembershipPolicy.new(@admin_membership, @user_membership), :edit?
  end

  test "membership update available if admin" do
    assert_not_predicate MembershipPolicy.new(nil, @user_membership), :update?
    assert_not_predicate MembershipPolicy.new(@user_membership, @user_membership), :update?

    assert_predicate MembershipPolicy.new(@admin_membership, @user_membership), :update?
  end

  test "membership destroy available if admin or owner" do
    assert_not_predicate MembershipPolicy.new(nil, @user_membership), :destroy?

    assert_predicate MembershipPolicy.new(@user_membership, @user_membership), :destroy?
    assert_predicate MembershipPolicy.new(@admin_membership, @user_membership), :destroy?
  end
end
