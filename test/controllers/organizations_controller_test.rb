# frozen_string_literal: true

require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:feedbackbin)

    @user = users(:shane)
    sign_in @user
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
      post organizations_url, params: {organization: {name: "ACME Corp"}}
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
    patch organization_url(@organization), params: {organization: {name: @organization.name}}

    assert_redirected_to organization_url(@organization)
  end

  test "should destroy organization" do
    assert_difference("Organization.count", -1) do
      delete organization_url(@organization)
    end

    assert_redirected_to organizations_url
  end
end
