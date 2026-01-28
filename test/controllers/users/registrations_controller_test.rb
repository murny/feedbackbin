# frozen_string_literal: true

require "test_helper"

module Users
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @account = accounts(:feedbackbin)
    end

    test "should get new" do
      tenanted(@account) do
        get users_sign_up_url

        assert_response :success
        assert_select "h1", text: /Create your account/
      end
    end

    test "should register new user for account" do
      tenanted(@account) do
        assert_difference [ "User.count", "Identity.count" ] do
          post users_registrations_url, params: { user: {
            name: "New User",
            email_address: "new_user@example.com",
            password: "password123456",
            password_confirmation: "password123456"
          } }
        end

        assert_enqueued_email_with IdentityMailer, :email_verification, args: [ Identity.last ]

        # After registration, redirects to pending email verification page
        assert_redirected_to pending_users_email_verification_path
        assert_equal "We've sent you an email to verify your address. Please check your inbox to complete your registration.", flash[:notice]

        # User should be created for the correct account
        user = User.last

        assert_equal @account, user.account
        assert_equal "member", user.role

        # User should not be signed in yet (email not verified)
        assert_nil Identity.last.email_verified_at
      end
    end

    test "should reject registration with already registered email" do
      # Try to register with an email that already has an identity
      identity = identities(:shane)

      tenanted(@account) do
        assert_no_difference [ "User.count", "Identity.count" ] do
          post users_registrations_url, params: { user: {
            name: "Shane Duplicate",
            email_address: identity.email_address,
            password: "password123456",
            password_confirmation: "password123456"
          } }
        end

        assert_response :unprocessable_entity
      end
    end

    test "should not register with invalid data" do
      tenanted(@account) do
        assert_no_difference [ "User.count", "Identity.count" ] do
          assert_no_enqueued_emails do
            post users_registrations_url, params: { user: {
              name: "Jane Doe",
              email_address: "bad_email",
              password: "password123456",
              password_confirmation: "password123456"
            } }
          end
        end

        assert_response :unprocessable_entity
      end
    end

    test "should redirect authenticated user who already has user for account" do
      tenanted(@account) do
        sign_in_as :shane

        get users_sign_up_url

        assert_redirected_to root_path
      end
    end

    test "should auto-join account for authenticated user without membership" do
      # Create a new account where the user doesn't have a membership
      new_account = Account.create!(name: "Auto Join Test Account")
      shane = users(:shane)

      # Sign in as shane (in the original account context first)
      tenanted(@account) do
        sign_in_as shane
      end

      # Now visit the new account's sign up page
      tenanted(new_account) do
        assert_difference "User.count" do
          get users_sign_up_url
        end

        assert_redirected_to root_path
        assert_match /joined/, flash[:notice]

        # User should be created for the new account
        new_user = shane.identity.users.find_by(account: new_account)

        assert_not_nil new_user
        assert_equal "member", new_user.role
      end
    end

    test "should block deactivated user from auto-joining" do
      # Create a new account where the user has a deactivated membership
      new_account = Account.create!(name: "Deactivated Test Account")
      shane = users(:shane)

      # Create and deactivate the user for this account
      User.create!(
        identity: shane.identity,
        account: new_account,
        name: "Shane",
        role: :member,
        active: false
      )

      # Sign in as shane
      tenanted(@account) do
        sign_in_as shane
      end

      # Try to visit the new account's sign up page
      tenanted(new_account) do
        assert_no_difference "User.count" do
          get users_sign_up_url
        end

        # Deactivated users are redirected to session menu to pick another account
        assert_redirected_to session_menu_path(script_name: nil)
        assert_match "Your user has been deactivated for this organization.", flash[:alert]
      end
    end

    test "should show account branding" do
      tenanted(@account) do
        get users_sign_up_url

        assert_response :success
        assert_select "span", text: @account.name
      end
    end
  end
end
