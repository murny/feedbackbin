# frozen_string_literal: true

require "test_helper"

class UserSettings::PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:shane))
  end

  test "should be able to update password" do
    patch user_settings_password_url, params: {password: "password123", password_confirmation: "password123", password_challenge: "secret123456"}

    assert_redirected_to user_settings_password_url
    assert_equal "Your password has been changed.", flash[:notice]
  end
end