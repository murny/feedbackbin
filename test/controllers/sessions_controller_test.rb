# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:shane)
  end

  test "should get new" do
    get sign_in_url

    assert_response :success
  end

  test "should sign in" do
    post session_url, params: {email_address: @user.email_address, password: "secret123456"}

    assert_redirected_to root_url
  end

  test "should not sign in with wrong credentials" do
    post session_url, params: {email_address: @user.email_address, password: "SecretWrong1*3"}

    assert_redirected_to sign_in_url
    assert_equal "Try another email address or password.", flash[:alert]
  end

  test "should sign out" do
    sign_in(@user)

    delete session_url(@user.sessions.last)

    assert_redirected_to sign_in_url
  end
end
