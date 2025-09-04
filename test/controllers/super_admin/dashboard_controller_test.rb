# frozen_string_literal: true

require "test_helper"

module SuperAdmin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    test "should not get show when not logged in" do
      get super_admin_root_url

      assert_response :not_found
    end

    test "should not get show as non admin user" do
      sign_in_as users(:one)

      get super_admin_root_url

      assert_response :not_found
    end

    test "should get show as admin" do
      sign_in_as users(:shane)

      get super_admin_root_url

      assert_response :success
    end
  end
end
