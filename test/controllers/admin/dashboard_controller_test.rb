# frozen_string_literal: true

require "test_helper"

module Admin
  class DashboardControllerTest < ActionDispatch::IntegrationTest
    test "should get show" do
      sign_in_as users(:shane)

      get admin_root_url

      assert_response :success
    end
  end
end
