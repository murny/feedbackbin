# frozen_string_literal: true

require "test_helper"

class Users::OmniauthControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
  end

  test "should handle previously connected user account" do
    user_connected_account = user_connected_accounts(:shane_google)

    OmniAuth.config.add_mock(:google, uid: user_connected_account.provider_uid,
      info: {email: "shane.murnaghan@feedbackbin.com", name: "Shane Murnaghan", nickname: "murny"})

    get "/auth/google/callback"

    assert_redirected_to root_path
    assert_equal "You have signed in successfully.", flash[:notice]
  end

  test "can register and login with a social account" do
    OmniAuth.config.mock_auth[:developer] = OmniAuth::AuthHash.new(
      provider: "developer",
      uid: "12345",
      info: {
        email: "harrypotter@hogwarts.com",
        name: "Harry Potter"
      }
    )
    assert_difference "UserConnectedAccount.count" do
      assert_difference "User.count" do
        get "/auth/developer/callback"

        assert_redirected_to root_path
        assert_equal "You have signed in successfully.", flash[:notice]
      end
    end

    user = User.last

    assert_equal "harrypotter@hogwarts.com", user.email_address
    assert_equal "Harry Potter", user.name
    assert_equal "HarryPotter", user.username
    assert_equal "developer", user.user_connected_accounts.last.provider_name
    assert_equal "12345", user.user_connected_accounts.last.provider_uid
  end

  test "can connect to a social account when signed in" do
    user = users(:shane)

    sign_in user

    OmniAuth.config.mock_auth[:developer] = OmniAuth::AuthHash.new(
      provider: "developer",
      uid: "54321",
      info: {
        email: user.email_address
      }
    )

    assert_difference "UserConnectedAccount.count" do
      get "/auth/developer/callback"

      assert_redirected_to user_settings_account_url
      assert_equal "You have connected your developer account successfully.", flash[:notice]
    end

    assert_equal "developer", user.user_connected_accounts.last.provider_name
    assert_equal "54321", user.user_connected_accounts.last.provider_uid
  end

  test "can log in while connecting a new social account to an existing user" do
    user = users(:shane)

    OmniAuth.config.mock_auth[:developer] = OmniAuth::AuthHash.new(
      provider: "developer",
      uid: "11111",
      info: {
        email: user.email_address
      }
    )

    assert_difference "UserConnectedAccount.count" do
      get "/auth/developer/callback"

      assert_redirected_to root_path
      assert_equal "You have signed in successfully.", flash[:notice]
    end

    assert_equal "developer", user.user_connected_accounts.last.provider_name
    assert_equal "11111", user.user_connected_accounts.last.provider_uid
  end

  test "cannot connect with account if connected to another user" do
    connected_account = user_connected_accounts(:shane_google)
    user = users(:invited)

    # Ensure these are separate users
    assert_not_equal connected_account.user, user

    sign_in user
    OmniAuth.config.add_mock(:google, uid: connected_account.provider_uid, info: {email: connected_account.user.email_address})
    get "/auth/google/callback"

    assert_predicate user.user_connected_accounts, :none?
    assert_equal "This google account is already connected to another account.", flash[:alert]
  end

  test "can connect to a social account when signed in and previously connected" do
    connected_account = user_connected_accounts(:shane_google)
    user = connected_account.user

    sign_in user

    OmniAuth.config.add_mock(:google, uid: connected_account.provider_uid, info: {email: connected_account.user.email_address})

    get "/auth/google/callback"

    assert_redirected_to user_settings_account_path
    assert_equal "This google account is already connected to your account.", flash[:notice]
  end

  test "when creating a new user, should send user to registration page if failure" do
    OmniAuth.config.add_mock(:developer, uid: "test", info: {name: "No email given"})

    assert_no_difference "User.count" do
      get "/auth/developer/callback"
    end

    assert_redirected_to sign_up_path(user: {email_address: "", name: "No email given", username: "Noemailgiven"})
    assert_equal "We could not create an account for you. Please finish the registration process.", flash[:alert]
  end

  test "should handle invalid credentials" do
    OmniAuth.config.mock_auth[:developer] = :invalid_credentials

    get "/auth/developer/callback"

    assert_redirected_to auth_failure_path(message: "invalid_credentials", strategy: "developer")
    follow_redirect!

    assert_redirected_to root_path
    assert_equal "Something went wrong, please try again.", flash[:alert]
  end

  test "should handle failure" do
    get "/auth/failure"

    assert_redirected_to root_path
    assert_equal "Something went wrong, please try again.", flash[:alert]
  end
end
