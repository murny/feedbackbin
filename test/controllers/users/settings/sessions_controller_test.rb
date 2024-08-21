# frozen_string_literal: true

require "test_helper"

class Users::Settings::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:shane))
  end

  test "should be able to view sessions" do
    get users_settings_sessions_url

    assert_response :success
  end
end
