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
    assert_difference "Organization.count", 1 do
      assert_difference "PostStatus.count", 5 do
        post organizations_url, params: { organization: { name: "ACME Corp", subdomain: "acme" } }
      end
    end

    assert_redirected_to admin_root_url(subdomain: Organization.last.subdomain)

    organization = Organization.last

    assert_equal "ACME Corp", organization.name
    assert_equal "Open", organization.default_post_status.name
  end
end
