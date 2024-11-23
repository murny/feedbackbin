# frozen_string_literal: true

require "test_helper"

class Membership::RoleTest < ActiveSupport::TestCase
  setup do
    @membership = memberships(:company_regular_user)
  end

  test "creating new users makes them members by default" do
    assert_predicate Membership.new(organization: @membership.organization, user: @membership.user), :member?
  end

  test "administer?" do
    @membership.role = :administrator

    assert_predicate @membership, :administrator?

    assert_not Membership.new(organization: @membership.organization, user: @membership.user, role: :member).administrator?
    assert_not Membership.new(organization: @membership.organization, user: @membership.user).administrator?
  end

  test "Roles must be a valid role" do
    @membership.role = :super_admin

    assert_not @membership.valid?
    assert_equal("is not included in the list", @membership.errors[:role].first)
  end
end
