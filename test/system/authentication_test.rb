# frozen_string_literal: true

require "application_system_test_case"

class AuthenticationTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

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
    visit sign_in_url(script_name: @account.slug)

    fill_in "Email", with: @user.identity.email_address
    fill_in "Password", with: "secret123456"

    click_button "Sign in"

    assert_text "You have signed in successfully."
  end

  test "registering and verifying email completes sign in" do
    email_address = "verify_test@example.com"

    visit users_sign_up_url(script_name: @account.slug)

    fill_in "Name", with: "New Member"
    fill_in "Email", with: email_address
    fill_in "Password", with: "SecretPassword123"

    click_button "Create account"

    assert_text "We've sent you an email to verify your address."
    assert_text "Check your email"

    # Get the newly created identity and generate verification URL
    identity = Identity.find_by(email_address: email_address)

    assert_not_nil identity, "Identity should have been created"
    assert_nil identity.email_verified_at, "Email should not be verified yet"

    token = identity.generate_token_for(:email_verification)

    # Visit the verification link
    visit users_email_verification_url(token: token, script_name: "")

    # User should now be signed in and see the account selection page
    assert_text "Thank you for verifying your email address"

    # Email should now be verified
    assert_not_nil identity.reload.email_verified_at, "Email should be verified"
  end
end
