# frozen_string_literal: true

require "test_helper"

class OrganizationPolicyTest < ActiveSupport::TestCase
  def setup
    @organization = organizations(:feedbackbin)
    @user = users(:one)
    @admin_user = users(:admin)
    @owner_user = users(:shane)
  end

  test "organization show viewable by admins" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :show?
    assert_not_predicate OrganizationPolicy.new(@user, @organization), :show?

    assert_predicate OrganizationPolicy.new(@admin_user, @organization), :show?
    assert_predicate OrganizationPolicy.new(@owner_user, @organization), :show?
  end

  test "organization create available by logged in users" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :create?

    assert_predicate OrganizationPolicy.new(@user, @organization), :create?
    assert_predicate OrganizationPolicy.new(@admin_user, @organization), :create?
    assert_predicate OrganizationPolicy.new(@owner_user, @organization), :create?
  end

  test "organization new available by logged in users" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :new?

    assert_predicate OrganizationPolicy.new(@user, @organization), :new?
    assert_predicate OrganizationPolicy.new(@admin_user, @organization), :new?
    assert_predicate OrganizationPolicy.new(@owner_user, @organization), :new?
  end

  test "organization edit available by admins" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :edit?
    assert_not_predicate OrganizationPolicy.new(@user, @organization), :edit?

    assert_predicate OrganizationPolicy.new(@admin_user, @organization), :edit?
    assert_predicate OrganizationPolicy.new(@owner_user, @organization), :edit?
  end

  test "organization update available by admins" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :update?
    assert_not_predicate OrganizationPolicy.new(@user, @organization), :update?

    assert_predicate OrganizationPolicy.new(@admin_user, @organization), :update?
    assert_predicate OrganizationPolicy.new(@owner_user, @organization), :update?
  end

  test "organization destroy only available to owner" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :destroy?
    assert_not_predicate OrganizationPolicy.new(@user, @organization), :destroy?

    # Create another admin who is not the owner
    other_admin = User.create!(
      name: "Admin Two",
      email_address: "admin2@feedbackbin.com",
      password: "password123456",
      role: :admin
    )

    assert_not_predicate OrganizationPolicy.new(other_admin, @organization), :destroy?

    # Only the owner (user with owner role) can destroy
    owner = users(:shane)

    assert_predicate OrganizationPolicy.new(owner, @organization), :destroy?
  end

  test "transfer_ownership only available to owner" do
    assert_not_predicate OrganizationPolicy.new(nil, @organization), :transfer_ownership?
    assert_not_predicate OrganizationPolicy.new(@user, @organization), :transfer_ownership?

    # Create another admin who is not the owner
    other_admin = User.create!(
      name: "Admin Three",
      email_address: "admin3@feedbackbin.com",
      password: "password123456",
      role: :admin
    )

    assert_not_predicate OrganizationPolicy.new(other_admin, @organization), :transfer_ownership?

    # Only the owner (user with owner role) can transfer ownership
    owner = users(:shane)

    assert_predicate OrganizationPolicy.new(owner, @organization), :transfer_ownership?
  end
end
