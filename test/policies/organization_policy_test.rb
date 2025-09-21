# frozen_string_literal: true

require "test_helper"

class OrganizationPolicyTest < ActiveSupport::TestCase
  def setup
    @organization = organizations(:feedbackbin)
    @user = users(:one)
    @admin_user = users(:shane)
  end

  test "organization show viewable by admins" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :show?
    assert_not_predicate OrganizationPolicy.new(@user, @organization), :show?

    assert_predicate OrganizationPolicy.new(@admin_user, @organization), :show?
  end

  test "organization create available by logged in users" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :create?

    assert_predicate OrganizationPolicy.new(@user, @organization), :create?
    assert_predicate OrganizationPolicy.new(@admin_user, @organization), :create?
  end

  test "organization new available by logged in users" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :new?

    assert_predicate OrganizationPolicy.new(@user, @organization), :new?
    assert_predicate OrganizationPolicy.new(@admin_user, @organization), :new?
  end

  test "organization edit available by administrators" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :edit?
    assert_not_predicate OrganizationPolicy.new(@user, @organization), :edit?

    assert_predicate OrganizationPolicy.new(@admin_user, @organization), :edit?
  end

  test "organization update available by administrators" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :update?
    assert_not_predicate OrganizationPolicy.new(@user, @organization), :update?

    assert_predicate OrganizationPolicy.new(@admin_user, @organization), :update?
  end

  test "organization destroy available by administrators" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :destroy?
    assert_not_predicate OrganizationPolicy.new(@user, @organization), :destroy?

    assert_predicate OrganizationPolicy.new(@admin_user, @organization), :destroy?
  end
end
