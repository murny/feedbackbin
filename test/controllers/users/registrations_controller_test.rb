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

        # After registration, stays in the same account context
        assert_redirected_to root_path
        assert_equal "Welcome! You have signed up successfully.", flash[:notice]

        # User should be created for the correct account
        user = User.last

        assert_equal @account, user.account
        assert_equal "member", user.role
      end
    end

    test "should register existing identity as new user for account" do
      # Create a new account where the identity doesn't have a user
      new_account = Account.create!(name: "Test Account for Registration")
      identity = identities(:shane)

      tenanted(new_account) do
        assert_difference "User.count" do
          assert_no_difference "Identity.count" do
            post users_registrations_url, params: { user: {
              name: "Shane in New Account",
              email_address: identity.email_address,
              password: "secret123456", # Must match existing identity password
              password_confirmation: "secret123456"
            } }
          end
        end

        assert_redirected_to root_path

        # User should be created for the correct account
        user = User.last

        assert_equal new_account, user.account
        assert_equal identity, user.identity
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
      deactivated_user = User.create!(
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

        assert_redirected_to root_path
        assert_match /deactivated/, flash[:alert]
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
