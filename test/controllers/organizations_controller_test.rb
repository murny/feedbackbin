# frozen_string_literal: true

require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:feedbackbin)

    @user = users(:shane)
    sign_in_as @user
  end


  test "should get new" do
    get new_organization_url

    assert_response :success
  end

  test "should create organization" do
    assert_difference("Organization.count") do
      post organizations_url, params: { organization: { name: "ACME Corp", subdomain: "acme" } }
    end

    assert_redirected_to admin_root_url(subdomain: Organization.last.subdomain)
    assert_equal @user, Organization.last.users.first
    assert_equal "administrator", @user.memberships.last.role
    assert Organization.last.owner?(@user)
  end
end
