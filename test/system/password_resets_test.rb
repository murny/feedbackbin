# frozen_string_literal: true

require "application_system_test_case"

class PasswordResetsTest < ApplicationSystemTestCase
  setup do
    @user = users(:shane)
  end

  test "updating password" do
    visit edit_users_password_reset_url(token: @user.identity.generate_token_for(:password_reset))

    fill_in "New password", with: "Secret6*4*2*"
    fill_in "Confirm new password", with: "Secret6*4*2*"
    click_button "Update password"

    assert_text "Password has been reset."
  end
end
