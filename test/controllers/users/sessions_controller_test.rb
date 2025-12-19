# frozen_string_literal: true

require "test_helper"

module Users
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:shane)
    end

    test "should get new" do
      get sign_in_url

      assert_response :success
    end

    test "new redirects to first run when no accounts exist" do
      Account.destroy_all

      get sign_in_url

      assert_redirected_to first_run_url
    end

    test "should sign in" do
      post users_session_url, params: { email_address: @user.identity.email_address, password: "secret123456" }

      assert_redirected_to root_url
      assert_equal "You have signed in successfully.", flash[:notice]
      assert cookies[:session_id]
    end

    test "should not sign in with wrong credentials" do
      post users_session_url, params: { email_address: @user.identity.email_address, password: "SecretWrong1*3" }

      assert_redirected_to sign_in_url
      assert_equal "Try another email address or password.", flash[:alert]
      assert_nil cookies[:session_id]
    end

    test "should not sign in when account is deactivated" do
      regular_user = users(:jane)
      email_address = regular_user.identity.email_address
      regular_user.deactivate

      post users_session_url, params: { email_address: email_address, password: "secret123456" }

      assert_redirected_to sign_in_url
      assert_equal "Your account has been deactivated. Please contact support for assistance.", flash[:alert]
      assert_nil cookies[:session_id]
    end

    test "should sign out" do
      sign_in_as(@user)

      delete users_session_url(@user.identity.sessions.last)

      assert_redirected_to sign_in_url
      assert_equal "You have signed out successfully.", flash[:notice]
      assert_empty cookies[:session_id]
    end
  end
end
