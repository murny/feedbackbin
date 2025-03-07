# frozen_string_literal: true

require "application_system_test_case"

class PasswordResetsTest < ApplicationSystemTestCase
  setup do
    @user = users(:shane)
  end

  # test "sending a password reset email" do
  #   visit sign_in_url

  #   click_link "Forgot your password?"

  #   fill_in "Email address", with: @user.email_address
  #   click_button "Email reset instructions"

  #   assert_text "Password reset instructions sent (if user with that email address exists)."
  # end

  test "updating password" do
    visit edit_users_password_reset_url(token: @user.password_reset_token)

    fill_in "New password", with: "Secret6*4*2*"
    fill_in "Confirm new password", with: "Secret6*4*2*"
    click_button "Update your password"

    assert_text "Password has been reset."
  end
end
