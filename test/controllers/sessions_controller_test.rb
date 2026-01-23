# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:shane)
  end

  test "should get new" do
    untenanted do
      get sign_in_url

      assert_response :success
      assert_select "h1", text: /Welcome back/
    end
  end

  test "new redirects to signup when no accounts exist" do
    Account.destroy_all

    untenanted do
      get sign_in_url

      assert_redirected_to signup_url
    end
  end

  test "should sign in" do
    untenanted do
      post session_url, params: { email_address: @user.identity.email_address, password: "secret123456" }

      # After sign in, redirects to session menu which will redirect to user's account
      assert_redirected_to session_menu_url
      assert_equal "You have signed in successfully.", flash[:notice]
      assert cookies[:session_token]
    end
  end

  test "should not sign in with wrong credentials" do
    untenanted do
      post session_url, params: { email_address: @user.identity.email_address, password: "SecretWrong1*3" }

      assert_response :unprocessable_entity
      assert_select "[role=alert]", text: /Try another email address or password/
      assert_nil cookies[:session_token]
    end
  end

  test "signs in even when all user accounts are deactivated" do
    # With untenanted auth, sign-in succeeds at identity level.
    # Deactivation is checked when entering a specific tenant.
    regular_user = users(:jane)
    email_address = regular_user.identity.email_address
    regular_user.identity.users.each(&:deactivate)

    untenanted do
      post session_url, params: { email_address: email_address, password: "secret123456" }

      # Sign in succeeds - redirects to session menu
      assert_redirected_to session_menu_url(script_name: nil)
      assert_predicate cookies[:session_token], :present?
    end
  end

  test "should sign out" do
    untenanted do
      sign_in_as(@user)

      delete session_url

      assert_redirected_to sign_in_url
      assert_equal "You have signed out successfully.", flash[:notice]
      assert_empty cookies[:session_token]
    end
  end

  test "redirects authenticated user away from sign in page" do
    untenanted do
      sign_in_as(@user)

      get sign_in_url

      assert_redirected_to session_menu_url
    end
  end
end
