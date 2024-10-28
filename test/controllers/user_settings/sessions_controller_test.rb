# frozen_string_literal: true

require "test_helper"

class UserSettings::ActiveSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:shane))
  end

  test "should be able to view sessions" do
    get user_settings_active_sessions_url

    assert_response :success
  end
end
