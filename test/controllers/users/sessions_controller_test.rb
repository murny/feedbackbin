# frozen_string_literal: true

require "test_helper"

module Users
  class SessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @account = accounts(:feedbackbin)
      @user = users(:shane)
    end

    test "should get new" do
      tenanted(@account) do
        get users_sign_in_url

        assert_response :success
        assert_select "h1", text: /Welcome back/
      end
    end

    test "should sign in existing user" do
      tenanted(@account) do
        post users_session_url, params: { email_address: @user.identity.email_address, password: "secret123456" }

        # After sign in, redirects to account root
        assert_redirected_to root_path
        assert_equal "You have signed in successfully.", flash[:notice]
        assert cookies[:session_token]
      end
    end

    test "should sign in and create user for new account" do
      # Create a new account where the user doesn't have a membership
      new_account = Account.create!(name: "New Test Account")

      tenanted(new_account) do
        assert_difference "User.count" do
          post users_session_url, params: { email_address: @user.identity.email_address, password: "secret123456" }
        end

        assert_redirected_to root_path
        assert_equal "You have signed in successfully.", flash[:notice]

        # User should be created for the new account
        new_user = @user.identity.users.find_by(account: new_account)

        assert_not_nil new_user
        assert_equal "member", new_user.role
      end
    end

    test "should not sign in with wrong credentials" do
      tenanted(@account) do
        post users_session_url, params: { email_address: @user.identity.email_address, password: "SecretWrong1*3" }

        assert_redirected_to users_sign_in_url
        assert_equal "Try another email address or password.", flash[:alert]
        assert_nil cookies[:session_token]
      end
    end

    test "should not sign in when user is deactivated for this account" do
      regular_user = users(:jane)
      email_address = regular_user.identity.email_address
      regular_user.deactivate

      tenanted(@account) do
        post users_session_url, params: { email_address: email_address, password: "secret123456" }

        assert_redirected_to users_sign_in_url
        assert_equal "Your account has been deactivated. Please contact support for assistance.", flash[:alert]
        assert_nil cookies[:session_token]
      end
    end

    test "should redirect authenticated user who already has user for account" do
      tenanted(@account) do
        sign_in_as(@user)

        get users_sign_in_url

        assert_redirected_to root_path
      end
    end

    test "should show account branding" do
      tenanted(@account) do
        get users_sign_in_url

        assert_response :success
        assert_select "span", text: @account.name
      end
    end
  end
end
