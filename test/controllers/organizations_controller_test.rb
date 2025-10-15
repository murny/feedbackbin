# frozen_string_literal: true

require "test_helper"

class OrganizationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:feedbackbin)
    @user = users(:shane)

    # Enable multi-tenant mode and reload routes
    Rails.application.config.multi_tenant = true
    Rails.application.routes_reloader.reload!
  end

  teardown do
    # Restore original multi-tenant setting and reload routes
    Rails.application.config.multi_tenant = false
    Rails.application.routes_reloader.reload!
  end

  test "should get new" do
    sign_in_as @user

    get new_organization_url(subdomain: "app")

    assert_response :success
  end

  test "should create organization" do
    sign_in_as @user

    assert_difference "Organization.count", 1 do
      assert_difference "PostStatus.count", 5 do
        post organizations_url(subdomain: "app"), params: { organization: { name: "ACME Corp", subdomain: "acme" } }
      end
    end

    assert_redirected_to admin_root_url(subdomain: Organization.last.subdomain)

    organization = Organization.last

    assert_equal "ACME Corp", organization.name
    assert_equal "Open", organization.default_post_status.name
  end
end
