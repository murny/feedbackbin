# frozen_string_literal: true

require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  setup do
    @user = users(:shane)
    @account = accounts(:feedbackbin)
  end

  test "signing in globally" do
    # Global sign-in page (no account scope)
    visit sign_in_url(script_name: nil)

    fill_in "Email", with: @user.identity.email_address
    fill_in "Password", with: "secret123456"

    click_button "Sign in"

    assert_text "You have signed in successfully."
  end

  test "signing up for new account" do
    # Global signup creates a new account/tenant
    visit signup_url(script_name: nil)

    fill_in "Name", with: "New Owner"
    fill_in "Email address", with: "newowner@example.com"
    fill_in "Password", with: "SecretPassword123"
    fill_in "Account Name", with: "My New Company"

    click_button "Create Account"

    assert_text "Your account has been created successfully."
  end

  test "signing in to account" do
    # Tenanted sign-in page
    visit users_sign_in_url(script_name: @account.slug)

    fill_in "Email", with: @user.identity.email_address
    fill_in "Password", with: "secret123456"

    click_button "Sign in"

    assert_text "You have signed in successfully."
  end

  test "registering for account" do
    # Tenanted registration (joining existing account)
    visit users_sign_up_url(script_name: @account.slug)

    fill_in "Name", with: "New Member"
    fill_in "Email", with: "newmember@example.com"
    fill_in "Password", with: "SecretPassword123"

    click_button "Create account"

    assert_text "Welcome! You have signed up successfully."
  end
end
