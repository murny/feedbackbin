# frozen_string_literal: true

require "test_helper"

class Users::EmailVerificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:shane)
    @user.update!(email_verified: false)
  end

  test "should send a verification email" do
    sign_in(@user)

    assert_enqueued_email_with UserMailer, :email_verification, args: [ @user ] do
      post users_email_verification_url
    end

    assert_redirected_to root_url
    assert_equal "We've sent you an email with a link to verify your email address", flash[:notice]
  end

  test "should verify email" do
    token = @user.generate_token_for(:email_verification)

    get users_email_verification_url(token: token, email_address: @user.email_address)

    assert_redirected_to root_url
    assert_equal "Thank you for verifying your email address", flash[:notice]
  end

  test "should not verify email with expired token" do
    token = @user.generate_token_for(:email_verification)

    travel 3.days

    get users_email_verification_url(token: token, email_address: @user.email_address)

    assert_redirected_to root_url
    assert_equal "That email verification link is invalid or has expired", flash[:alert]
  end
end
