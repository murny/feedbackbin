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
      post organizations_url, params: { organization: { name: "ACME Corp" } }
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
    get organizations_url, params: { search: "FeedbackBin" }

    assert_response :success
    assert_match @organization.name, response.body
  end

  test "should filter organizations by partial search" do
    get organizations_url, params: { search: "Feed" }

    assert_response :success
    assert_match @organization.name, response.body
  end

  test "should return empty results for non-matching search" do
    get organizations_url, params: { search: "NonExistentOrg" }

    assert_response :success
    # Check that the specific organization is not in the organizations list
    assert_match "No organizations found", response.body
    assert_match "No organizations match your search", response.body
  end

  test "should show all organizations when search is blank" do
    get organizations_url, params: { search: "" }

    assert_response :success
    assert_match @organization.name, response.body
  end

  test "should respond to turbo stream requests for search" do
    get organizations_url, params: { search: "Feed" }, as: :turbo_stream

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
    assert_match "turbo-stream", response.body
    assert_match @organization.name, response.body
  end

  test "search should be case insensitive" do
    get organizations_url, params: { search: "feedbackbin" }

    assert_response :success
    assert_match @organization.name, response.body
  end

  test "search should handle special characters safely" do
    # Create an organization with special characters
    special_org = Organization.create!(name: "Test%_Org", owner: @user)

    get organizations_url, params: { search: "Test%" }

    assert_response :success
    assert_match special_org.name, response.body
  end

  test "search should only show user's organizations" do
    # Create an organization that the current user is NOT a member of
    other_user = users(:one)
    other_org = Organization.create!(name: "FeedbackSearch", owner: other_user)

    get organizations_url, params: { search: "Feedback" }

    assert_response :success
    assert_match @organization.name, response.body # User's org should appear
    assert_no_match other_org.name, response.body # Other user's org should NOT appear
  end
end
