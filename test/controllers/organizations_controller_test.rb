# frozen_string_literal: true

require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:feedbackbin)

    @user = users(:shane)
    sign_in_as @user
  end

  test "should get index" do
    get organizations_url

    assert_response :success

    # displays only organizations that the user is a member of
    assert_match @organization.name, response.body

    other_organization = organizations(:other_organization)

    assert_no_match other_organization.name, response.body
  end

  test "should get new" do
    get new_organization_url

    assert_response :success
  end

  test "should create organization" do
    assert_difference("Organization.count") do
      post organizations_url, params: { organization: { name: "ACME Corp", categories_attributes: [ { name: "General" } ] } }
    end

    assert_redirected_to organization_url(Organization.last)
    assert_equal @user, Organization.last.users.first
    assert_equal "administrator", @user.memberships.last.role
    assert Organization.last.owner?(@user)
  end

  test "should show organization" do
    get organization_url(@organization)

    assert_response :success
  end

  test "should get edit" do
    get edit_organization_url(@organization)

    assert_response :success
  end

  test "should update organization" do
    patch organization_url(@organization), params: { organization: { name: @organization.name } }

    assert_redirected_to organization_url(@organization)
  end

  test "should destroy organization" do
    assert_difference("Organization.count", -1) do
      delete organization_url(@organization)
    end

    assert_redirected_to organizations_url
  end

  # Search functionality tests
  test "should filter organizations by search parameter" do
    get organizations_url, params: { search: "Feedback" }

    assert_response :success
    assert_match @organization.name, response.body

    # Ensure orgs we are not a member of are excluded when searching
    assert_no_match organizations(:other_organization).name, response.body
  end

  test "should return empty results for non-matching search" do
    get organizations_url, params: { search: "NonExistentOrg" }

    assert_response :success
    # Check that the specific organization is not in the organizations list
    assert_match "No organizations found", response.body
    assert_match "No organizations match your search", response.body
  end
end
