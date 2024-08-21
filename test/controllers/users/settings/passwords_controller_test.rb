# frozen_string_literal: true

require "test_helper"

class Users::Settings::PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:shane))
  end

  test "should get edit" do
    get edit_users_settings_password_url

    assert_response :success
  end

  test "should be able to update password" do
    patch users_settings_password_url, params: {password: "password", password_confirmation: "password", password_challenge: "secret123456"}

    assert_redirected_to edit_users_settings_password_url
    assert_equal "Your password has been changed.", flash[:notice]
  end
end
