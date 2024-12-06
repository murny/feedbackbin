# frozen_string_literal: true

require "test_helper"

class OrganizationPolicyTest < ActiveSupport::TestCase
  def setup
    @organization = organizations(:feedbackbin)
    @user_membership = memberships(:feedbackbin_regular_user_one)
    @admin_membership = memberships(:feedbackbin_admin)
    @different_organization_membership = memberships(:company_regular_user)
  end

  test "organization index viewable by anyone with a membership" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :index?
    assert_predicate OrganizationPolicy.new(@user_membership, @organization), :index?
  end

  test "organization show viewable by members" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :show?
    assert_not_predicate OrganizationPolicy.new(@different_organization_membership, @organization), :show?

    assert_predicate OrganizationPolicy.new(@user_membership, @organization), :show?
    assert_predicate OrganizationPolicy.new(@admin_membership, @organization), :show?
  end

  test "organization create available by logged in users" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :create?

    assert_predicate OrganizationPolicy.new(@different_organization_membership, @organization), :create?
    assert_predicate OrganizationPolicy.new(@user_membership, @organization), :create?
    assert_predicate OrganizationPolicy.new(@admin_membership, @organization), :create?
  end

  test "organization new available by logged in users" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :new?

    assert_predicate OrganizationPolicy.new(@different_organization_membership, @organization), :new?
    assert_predicate OrganizationPolicy.new(@user_membership, @organization), :new?
    assert_predicate OrganizationPolicy.new(@admin_membership, @organization), :new?
  end

  test "organization edit available by organization admin" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :edit?
    assert_not_predicate OrganizationPolicy.new(@different_organization_membership, @organization), :edit?
    assert_not_predicate OrganizationPolicy.new(@user_membership, @organization), :edit?

    assert_predicate OrganizationPolicy.new(@admin_membership, @organization), :edit?
  end

  test "organization update available by organization admin" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :update?
    assert_not_predicate OrganizationPolicy.new(@different_organization_membership, @organization), :update?
    assert_not_predicate OrganizationPolicy.new(@user_membership, @organization), :update?

    assert_predicate OrganizationPolicy.new(@admin_membership, @organization), :update?
  end

  test "organization destroy available by organization admin" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :destroy?
    assert_not_predicate OrganizationPolicy.new(@different_organization_membership, @organization), :destroy?
    assert_not_predicate OrganizationPolicy.new(@user_membership, @organization), :destroy?

    assert_predicate OrganizationPolicy.new(@admin_membership, @organization), :destroy?
  end
end
