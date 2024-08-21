# frozen_string_literal: true

require "test_helper"

class Users::Settings::EmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:shane))
  end

  test "should get edit" do
    get edit_users_settings_email_url

    assert_response :success
  end

  test "should be able to update email" do
    patch users_settings_email_url, params: {email_address: "new_email@example.com", password_challenge: "secret123456"}

    assert_redirected_to edit_users_settings_email_url
    assert_equal "Your email address has been changed.", flash[:notice]
  end
end
