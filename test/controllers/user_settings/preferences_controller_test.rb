# frozen_string_literal: true

require "test_helper"

module UserSettings
  class PreferencesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as(users(:one))
    end

    test "should get show" do
      get user_settings_preferences_url

      assert_response :success
    end

    test "should be able to update preferences" do
      patch user_settings_preferences_url, params: { user: { theme: "dark" } }

      assert_redirected_to user_settings_preferences_url
      assert_equal "Your preferences have been updated.", flash[:notice]
    end
  end
end
