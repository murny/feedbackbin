# frozen_string_literal: true

require "test_helper"

module UserSettings
  class ProfilesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as(users(:one))
    end

    test "should get show" do
      get user_settings_profile_url

      assert_response :success
    end

    test "should be able to update profile" do
      patch user_settings_profile_url, params: { user: { name: "Murny", bio: "I am a developer" } }

      assert_redirected_to user_settings_profile_url
      assert_equal "Your profile has been updated.", flash[:notice]
    end
  end
end
