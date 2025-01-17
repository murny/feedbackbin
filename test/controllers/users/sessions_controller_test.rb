# frozen_string_literal: true

require "test_helper"

class Users::SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:shane)
  end

  test "should get new" do
    get sign_in_url

    assert_response :success
  end

  test "new redirects to first run when no users exist" do
    User.destroy_all

    get sign_in_url

    assert_redirected_to first_run_url
  end

  test "should sign in" do
    post users_session_url, params: { email_address: @user.email_address, password: "secret123456" }

    assert_redirected_to root_url
    assert_equal "You have signed in successfully.", flash[:notice]
  end

  test "should not sign in with wrong credentials" do
    post users_session_url, params: { email_address: @user.email_address, password: "SecretWrong1*3" }

    assert_redirected_to sign_in_url
    assert_equal "Try another email address or password.", flash[:alert]
  end

  test "should sign out" do
    sign_in(@user)

    delete users_session_url(@user.sessions.last)

    assert_redirected_to sign_in_url
    assert_equal "You have signed out successfully.", flash[:notice]
  end
end
