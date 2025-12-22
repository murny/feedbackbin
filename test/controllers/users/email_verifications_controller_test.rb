# frozen_string_literal: true

require "test_helper"

module Users
  class EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:shane)
      @identity = @user.identity
      @identity.update!(email_verified: false)
      # Email verifications controller uses disallow_account_scope
      integration_session.default_url_options[:script_name] = ""
    end

    test "should send a verification email" do
      sign_in_as(@user)
      # After sign_in_as, reset script_name to empty for disallow_account_scope controller
      integration_session.default_url_options[:script_name] = ""

      assert_enqueued_email_with IdentityMailer, :email_verification, args: [ @identity ] do
        post users_email_verification_url
      end

      # Redirects to session menu which will redirect to user's account
      assert_redirected_to session_menu_url
      assert_equal "We've sent you an email with a link to verify your email address", flash[:notice]
    end

    test "should verify email" do
      token = @identity.generate_token_for(:email_verification)

      get users_email_verification_url(token: token, email_address: @identity.email_address)

      # Redirects to session menu which will redirect to user's account
      assert_redirected_to session_menu_url
      assert_equal "Thank you for verifying your email address", flash[:notice]
    end

    test "should not verify email with expired token" do
      token = @identity.generate_token_for(:email_verification)

      travel 3.days

      get users_email_verification_url(token: token, email_address: @identity.email_address)

      # Redirects to sign in when not authenticated (token expired)
      assert_redirected_to sign_in_url
      assert_equal "That email verification link is invalid or has expired", flash[:alert]
    end
  end
end
