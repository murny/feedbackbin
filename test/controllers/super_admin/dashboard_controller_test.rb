# frozen_string_literal: true

require "test_helper"

module SuperAdmin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    setup do
      # Enable multi-tenant mode and reload routes
      Rails.application.config.multi_tenant = true
      Rails.application.routes_reloader.reload!
    end

    teardown do
      # Restore original multi-tenant setting and reload routes
      Rails.application.config.multi_tenant = false
      Rails.application.routes_reloader.reload!
    end

    test "should not get show when not logged in" do
      get super_admin_root_url(subdomain: "app")

      assert_response :not_found
    end

    test "should not get show as non admin user" do
      sign_in_as users(:one)

      get super_admin_root_url(subdomain: "app")

      assert_response :not_found
    end

    test "should get show as admin" do
      sign_in_as users(:shane)

      get super_admin_root_url(subdomain: "app")

      assert_response :success
    end
  end
end
