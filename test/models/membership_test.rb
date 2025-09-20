# frozen_string_literal: true

require "test_helper"

class MembershipTest < ActiveSupport::TestCase
  setup do
    @regular_membership = memberships(:feedbackbin_regular_user_one)
  end

  test "valid membership" do
    assert_predicate @regular_membership, :valid?
  end

  test "invalid without user" do
    @regular_membership.user = nil

    assert_not_predicate @regular_membership, :valid?
    assert_equal "must exist", @regular_membership.errors[:user].first
  end

  test "invalid without organization" do
    @regular_membership.organization = nil

    assert_not_predicate @regular_membership, :valid?
    assert_equal "must exist", @regular_membership.errors[:organization].first
  end

  test "invalid if user is duplicated on same organization" do
    new_membership = Membership.new(organization: @regular_membership.organization, user: @regular_membership.user)

    assert_not_predicate new_membership, :valid?
    assert_equal "has already been taken", new_membership.errors[:user].first
  end

  test "organization_owner?" do
    assert_not_predicate @regular_membership, :organization_owner?

    owner = memberships(:feedbackbin_admin)

    assert_predicate owner, :organization_owner?
  end

  test "invalid if removing owner as administrator" do
    owner = memberships(:feedbackbin_admin)

    owner.role = :member

    assert_not_predicate owner, :valid?
    assert_equal "administrator role cannot be removed for the organization owner", owner.errors[:role].first
  end
end
