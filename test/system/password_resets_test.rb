# frozen_string_literal: true

require "application_system_test_case"

class PasswordResetsTest < ApplicationSystemTestCase
  setup do
    @identity = identities(:shane)
  end

  test "updating password" do
    # Password reset pages use global URLs (no account scope)
    visit edit_users_password_reset_url(token: @identity.password_reset_token, script_name: nil)

    fill_in "New password", with: "Secret6*4*2*"
    fill_in "Confirm new password", with: "Secret6*4*2*"
    click_button "Update password"

    assert_text "Password has been reset."
  end
end
