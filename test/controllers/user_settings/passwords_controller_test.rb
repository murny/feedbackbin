# frozen_string_literal: true

require "test_helper"

module UserSettings
  class PasswordsControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as(users(:one))
    end

  test "should get show" do
    get user_settings_password_url

    assert_response :success
  end

  test "should be able to update password" do
    patch user_settings_password_url, params: { user: {
      password: "password123", password_confirmation: "password123", password_challenge: "secret123456"
    } }

    assert_redirected_to user_settings_password_url
    assert_equal "Your password has been changed.", flash[:notice]
  end
  end
end
