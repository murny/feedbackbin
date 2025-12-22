# frozen_string_literal: true

require "test_helper"

module Users
  class OmniauthControllerTest < ActionDispatch::IntegrationTest
    setup do
      OmniAuth.config.test_mode = true
      # Omniauth controller uses disallow_account_scope
      integration_session.default_url_options[:script_name] = ""
    end

    test "should handle previously connected identity account" do
      identity_connected_account = identity_connected_accounts(:shane_google)

      OmniAuth.config.add_mock(:google, uid: identity_connected_account.provider_uid,
        info: { email: "shane.murnaghan@feedbackbin.com", name: "Shane Murnaghan", nickname: "murny" })

      get "/auth/google/callback"

      # After login, redirects to session menu which will redirect to user's account
      assert_redirected_to session_menu_url
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
      assert_difference "IdentityConnectedAccount.count" do
        assert_difference [ "User.count", "Identity.count" ] do
          get "/auth/developer/callback"
        end
      end

      user = User.last

      # After registration/login, redirects to session menu which will redirect to user's account
      assert_redirected_to session_menu_url
      assert_equal "You have signed in successfully.", flash[:notice]

      assert_equal "harrypotter@hogwarts.com", user.identity.email_address
      assert_equal "Harry Potter", user.name
      assert_equal "developer", user.identity.identity_connected_accounts.last.provider_name
      assert_equal "12345", user.identity.identity_connected_accounts.last.provider_uid
    end

    test "can connect to a social account when signed in" do
      user = users(:shane)

      sign_in_as user
      # After sign_in_as, set script_name back to empty for disallow_account_scope controller
      integration_session.default_url_options[:script_name] = ""

      OmniAuth.config.mock_auth[:developer] = OmniAuth::AuthHash.new(
        provider: "developer",
        uid: "54321",
        info: {
          email: user.identity.email_address
        }
      )

      assert_difference "IdentityConnectedAccount.count" do
        get "/auth/developer/callback"

        # Redirects to session menu which will redirect to user's account
        assert_redirected_to session_menu_url
        assert_equal "You have connected your developer account successfully.", flash[:notice]
      end

      assert_equal "developer", user.identity.identity_connected_accounts.last.provider_name
      assert_equal "54321", user.identity.identity_connected_accounts.last.provider_uid
    end

    test "can log in while connecting a new social account to an existing identity" do
      user = users(:shane)

      OmniAuth.config.mock_auth[:developer] = OmniAuth::AuthHash.new(
        provider: "developer",
        uid: "11111",
        info: {
          email: user.identity.email_address
        }
      )

      assert_difference "IdentityConnectedAccount.count" do
        get "/auth/developer/callback"

        # After login, redirects to session menu which will redirect to user's account
        assert_redirected_to session_menu_url
        assert_equal "You have signed in successfully.", flash[:notice]
      end

      assert_equal "developer", user.identity.identity_connected_accounts.last.provider_name
      assert_equal "11111", user.identity.identity_connected_accounts.last.provider_uid
    end

    test "cannot connect with account if connected to another identity" do
      connected_account = identity_connected_accounts(:shane_google)
      user = users(:john)

      # Ensure these are separate identities
      assert_not_equal connected_account.identity, user.identity

      sign_in_as user
      # After sign_in_as, set script_name back to empty for disallow_account_scope controller
      integration_session.default_url_options[:script_name] = ""

      OmniAuth.config.add_mock(
        :google,
        uid: connected_account.provider_uid,
        info: { email: connected_account.identity.email_address }
      )

      assert_no_difference "IdentityConnectedAccount.count" do
        get "/auth/google/callback"
      end

      # Redirects to session menu which will redirect to user's account
      assert_redirected_to session_menu_url
      assert_equal "This google account is already connected to another account.", flash[:alert]
    end

    test "can connect to a social account when signed in and previously connected" do
      connected_account = identity_connected_accounts(:shane_google)
      user = connected_account.identity.users.first

      sign_in_as user
      # After sign_in_as, set script_name back to empty for disallow_account_scope controller
      integration_session.default_url_options[:script_name] = ""

      OmniAuth.config.add_mock(
        :google,
        uid: connected_account.provider_uid,
        info: { email: connected_account.identity.email_address }
      )

      get "/auth/google/callback"

      # Redirects to session menu which will redirect to user's account
      assert_redirected_to session_menu_url
      assert_equal "This google account is already connected to your account.", flash[:notice]
    end

    test "when creating a new user, should send user to registration page if failure" do
      OmniAuth.config.add_mock(:developer, uid: "test", info: { name: "No email given" })

      assert_no_difference "User.count" do
        get "/auth/developer/callback"
      end

      assert_redirected_to sign_up_path(user: {
        email_address: nil,
        name: "No email given"
      })

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
end
