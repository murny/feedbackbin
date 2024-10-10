# frozen_string_literal: true

require "test_helper"

class Users::Settings::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:shane))
  end

  test "should be able to update email" do
    patch users_settings_email_url, params: {user: {email_address: "new_email@example.com", password_challenge: "secret123456"}}

    assert_redirected_to users_settings_account_url
    assert_equal "Your email address has been changed.", flash[:notice]
  end
end
