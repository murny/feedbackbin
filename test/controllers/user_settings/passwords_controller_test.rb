# frozen_string_literal: true

require "test_helper"

module UserSettings
  class PasswordsControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as(users(:jane))
    end

    test "should get show" do
      get user_settings_password_url

      assert_response :success
    end

    test "should be able to update password" do
      patch user_settings_password_url, params: { identity: {
        password: "password123456", password_confirmation: "password123456", password_challenge: "secret123456"
      } }

      assert_redirected_to user_settings_password_url
      assert_equal "Your password has been changed.", flash[:notice]
    end
  end
end
