# frozen_string_literal: true

require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  setup do
    @user = users(:shane)
  end

  test "signing in" do
    visit sign_in_url

    fill_in "Email", with: @user.email_address
    fill_in "Password", with: "secret123456"

    click_button "Sign in"

    assert_text "You have signed in successfully."
  end

  test "signing out" do
    sign_in @user.email_address

    find_by_id("user-menu-button").click
    click_button "Sign out"

    assert_text "You have signed out successfully."
  end

  test "signing up" do
    visit sign_up_url

    fill_in "Name", with: "Shane"
    fill_in "Email address", with: "shane@email.com"
    fill_in "Password", with: "SecretPassword"

    click_button "Create account"

    assert_text "Welcome! You have signed up successfully"
  end
end
