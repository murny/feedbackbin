# frozen_string_literal: true

require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:shane)
  end

  test "should get new" do
    get new_password_url

    assert_response :success
  end

  test "should get edit" do
    get edit_password_url(token: @user.password_reset_token)

    assert_response :success
  end

  test "should send a password reset email" do
    assert_enqueued_email_with PasswordsMailer, :reset, args: [@user] do
      post passwords_url, params: {email_address: @user.email_address}
    end

    assert_redirected_to sign_in_url
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end

  test "should not send a password reset email to a nonexistent email" do
    assert_no_enqueued_emails do
      post passwords_url, params: {email_address: "invalid_email@example.com"}
    end

    assert_redirected_to new_password_url
    assert_equal "You can't reset your password until you verify your email", flash[:alert]
  end

  test "should not send a password reset email to a unverified email" do
    @user.update!(email_verified: false)

    assert_no_enqueued_emails do
      post passwords_url, params: {email_address: @user.email_address}
    end

    assert_redirected_to new_password_url
    assert_equal "You can't reset your password until you verify your email", flash[:alert]
  end

  test "should update password" do
    patch password_url(token: @user.password_reset_token), params: {password: "Secret1*2*3*", password_confirmation: "Secret1*2*3*"}

    assert_redirected_to sign_in_url
    assert_equal "Password has been reset.", flash[:notice]
  end

  test "should not update password when password confirmation does not match" do
    patch password_url(token: @user.password_reset_token), params: {password: "Secret1*2*3*", password_confirmation: "password"}

    assert_redirected_to edit_password_url
    assert_equal "Passwords did not match.", flash[:alert]
  end

  test "should not update password with expired token" do
    token = @user.password_reset_token

    travel 16.minutes

    patch password_url(token: token), params: {password: "Secret1*2*3*", password_confirmation: "Secret1*2*3*"}

    assert_redirected_to new_password_url
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end
end
