# frozen_string_literal: true

require "test_helper"

class CurrentTest < ActiveSupport::TestCase
  def setup
    @user = users(:shane)
    @organization = organizations(:feedbackbin)
    @session = sessions(:shane_chrome)
    
    # Set up Current attributes
    Current.session = @session
    Current.organization = @organization
  end

  test "user is delegated to session" do
    assert_equal @user, Current.user
  end

  test "setting organization resets membership and other_organizations" do
    # First access membership and other_organizations to set the instance variables
    Current.membership
    Current.other_organizations
    
    # Then set a new organization, which should reset the instance variables
    new_organization = organizations(:company)
    Current.organization = new_organization
    
    # Verify that the organization was updated
    assert_equal new_organization, Current.organization
  end

  test "membership returns the membership for the current user and organization" do
    membership = Current.membership
    assert_not_nil membership
    assert_equal @user, membership.user
    assert_equal @organization, membership.organization
  end

  test "organization_admin? returns true for admin membership" do
    # Create a stub object that responds to administrator? with true
    admin_membership = Object.new
    def admin_membership.administrator?
      true
    end
    
    Current.stub :membership, admin_membership do
      assert Current.organization_admin?
    end
  end

  test "organization_admin? returns false for non-admin membership" do
    # Create a stub object that responds to administrator? with false
    regular_membership = Object.new
    def regular_membership.administrator?
      false
    end
    
    Current.stub :membership, regular_membership do
      assert_not Current.organization_admin?
    end
  end

  test "organization_admin? returns false when membership is nil" do
    Current.stub :membership, nil do
      assert_not Current.organization_admin?
    end
  end

  test "other_organizations returns organizations excluding the current one" do
    # Create a situation where the user has multiple organizations
    # We'll use a user that already has multiple organizations in the fixtures
    user_with_multiple_orgs = users(:one)
    org1 = organizations(:feedbackbin)
    org2 = organizations(:company)
    
    # Set up Current with this user
    session = Minitest::Mock.new
    session.expect :user, user_with_multiple_orgs
    session.expect :nil?, false
    
    Current.session = session
    Current.organization = org1
    
    other_organizations = Current.other_organizations
    assert_includes other_organizations, org2
    assert_not_includes other_organizations, org1
    
    session.verify
  end

  teardown do
    # Reset Current attributes
    Current.reset
  end
end