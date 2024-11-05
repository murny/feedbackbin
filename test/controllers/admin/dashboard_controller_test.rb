# frozen_string_literal: true

require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should not get show when not logged in" do
    get admin_root_url

    assert_response :not_found
  end

  test "should not get show as non admin user" do
    sign_in users(:one)

    get admin_root_url

    assert_response :not_found
  end

  test "should get show as admin" do
    sign_in users(:shane)

    get admin_root_url

    assert_response :success
  end
end
