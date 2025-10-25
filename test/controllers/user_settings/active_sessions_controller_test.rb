# frozen_string_literal: true

require "test_helper"

module UserSettings
  class ActiveSessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:one)
      sign_in_as(@user)
    end

    test "should be able to view sessions" do
      get user_settings_active_sessions_url

      assert_response :success
    end

    test "should be able to delete session" do
      session = @user.sessions.create(user_agent: "Test", ip_address: "192.168.1.1")

      delete user_settings_active_session_url(session)

      assert_redirected_to user_settings_active_sessions_url
      assert_equal "This session was successfully revoked", flash[:notice]
    end
  end
end
