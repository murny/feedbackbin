# frozen_string_literal: true

require "test_helper"

class UserSettings::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in(@user)
  end

  test "should be able to update email" do
    patch user_settings_email_url, params: {user: {email_address: "new_email@example.com", password_challenge: "secret123456"}}

    assert_redirected_to user_settings_account_url
    assert_equal "Your email address has been changed.", flash[:notice]
  end

  test "should not be able to update email with invalid password" do
    patch user_settings_email_url, params: {user: {email_address: "new_email@example.com", password_challenge: "invalid"}}

    assert_response :unprocessable_entity
  end

  test "if email has not changed" do
    patch user_settings_email_url, params: {user: {email_address: @user.email_address, password_challenge: "secret123456"}}

    assert_redirected_to user_settings_account_url
    assert_equal "You provided the same email address, nothing has changed.", flash[:notice]
  end
end
