# frozen_string_literal: true

require "test_helper"

module Users
  class PasswordResetsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:shane)
      @identity = @user.identity
    end

    test "should get new" do
      get new_users_password_reset_url

      assert_response :success
    end

    test "should get edit" do
      get edit_users_password_reset_url(token: @identity.password_reset_token)

      assert_response :success
    end

    test "should send a password reset email" do
      assert_enqueued_email_with IdentityMailer, :password_reset, args: [ @identity ] do
        post users_password_resets_url, params: { email_address: @identity.email_address }
      end

      assert_redirected_to sign_in_url
      assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
    end

    test "should not send a password reset email to a nonexistent email" do
      assert_no_enqueued_emails do
        post users_password_resets_url, params: { email_address: "invalid_email@example.com" }
      end

      assert_redirected_to sign_in_url
      assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
    end

    test "should not send a password reset email to an unverified email" do
      @identity.update!(email_verified: false)

      assert_no_enqueued_emails do
        post users_password_resets_url, params: { email_address: @identity.email_address }
      end

      assert_redirected_to sign_in_url
      assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
    end

    test "should update password" do
      patch users_password_reset_url(token: @identity.password_reset_token), params: {
        password: "Secret1*2*3*",
        password_confirmation: "Secret1*2*3*"
      }

      assert_redirected_to sign_in_url
      assert_equal "Password has been reset.", flash[:notice]
    end

    test "should not update password when password confirmation does not match" do
      patch users_password_reset_url(token: @identity.password_reset_token), params: {
        password: "Secret1*2*3*",
        password_confirmation: "password"
      }

      assert_redirected_to edit_users_password_reset_url
      assert_equal "Passwords did not match.", flash[:alert]
    end

    test "should not update password with expired token" do
      token = @identity.password_reset_token

      travel 21.minutes

      patch users_password_reset_url(token: token), params: {
        password: "Secret1*2*3*",
        password_confirmation: "Secret1*2*3*"
      }

      assert_redirected_to new_users_password_reset_url
      assert_equal "Password reset link is invalid or has expired.", flash[:alert]
    end

    test "should not update password when password is too short" do
      patch users_password_reset_url(token: @identity.password_reset_token), params: {
        password: "short",
        password_confirmation: "short"
      }

      assert_redirected_to edit_users_password_reset_url
      assert_equal "Password is invalid.", flash[:alert]
    end
  end
end
