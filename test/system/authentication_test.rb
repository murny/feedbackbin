# frozen_string_literal: true

require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  setup do
    @user = users(:shane)
  end

  test "signing in" do
    visit sign_in_url

    fill_in "Email", with: @user.identity.email_address
    fill_in "Password", with: "secret123456"

    click_button "Sign in"

    assert_text "You have signed in successfully."
  end

  test "signing up" do
    visit sign_up_url

    fill_in "Name", with: "Shane M"
    fill_in "Email", with: "shane@email.com"
    fill_in "Password", with: "SecretPassword"

    click_button "Create account"

    assert_text "Welcome! You have signed up successfully"
  end
end
