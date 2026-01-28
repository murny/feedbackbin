# frozen_string_literal: true

require "test_helper"

# Tests for session/authentication behavior when entering tenant scope.
# Sign-in works in both tenant and non-tenant contexts.
# User provisioning happens when entering tenant via ensure_account_user.
class TenantedSessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @account = accounts(:feedbackbin)
    @user = users(:shane)
  end

  test "sign in page works in tenant context with org branding" do
    tenanted(@account) do
      get sign_in_url

      assert_response :success
      assert_select "h1", text: /Welcome back/
      # Should show org branding
      assert_select "span", text: @account.name
    end
  end

  test "sign in from tenant context redirects to tenant root" do
    tenanted(@account) do
      post session_url, params: { email_address: @user.identity.email_address, password: "secret123456" }

      # Should redirect to tenant root, not session menu
      assert_redirected_to root_url
      assert_equal "You have signed in successfully.", flash[:notice]
    end
  end

  test "sign out from tenant context redirects to tenant sign in" do
    tenanted(@account) do
      post session_url, params: { email_address: @user.identity.email_address, password: "secret123456" }
      delete session_url

      assert_redirected_to sign_in_url
      assert_equal "You have signed out successfully.", flash[:notice]
    end
  end

  test "authenticated user entering tenant creates user if needed" do
    new_account = Account.create!(name: "New Test Account")

    # Sign in without tenant context
    untenanted do
      post session_url, params: { email_address: @user.identity.email_address, password: "secret123456" }
    end

    # Now enter the new tenant - should create user via ensure_account_user
    tenanted(new_account) do
      assert_difference "User.count" do
        get root_url
      end

      assert_response :success

      # User should be created for the new account
      new_user = @user.identity.users.find_by(account: new_account)

      assert_not_nil new_user
      assert_equal "member", new_user.role
    end
  end

  test "authenticated user with deactivated account is blocked when entering tenant" do
    regular_user = users(:jane)
    regular_user.deactivate

    # Sign in without tenant context
    untenanted do
      post session_url, params: { email_address: regular_user.identity.email_address, password: "secret123456" }

      assert_predicate cookies[:session_token], :present?
    end

    # Try to enter the tenant - should be blocked by ensure_can_access_account
    # User is redirected to session menu to pick another account (session preserved)
    tenanted(@account) do
      get root_url

      assert_redirected_to session_menu_path(script_name: nil)
      assert_match "Your user has been deactivated for this organization.", flash[:alert]

      assert_predicate cookies[:session_token], :present? # Session preserved for other accounts
    end
  end

  test "authenticated user entering tenant with existing active user succeeds" do
    # Sign in without tenant context
    untenanted do
      post session_url, params: { email_address: @user.identity.email_address, password: "secret123456" }
    end

    # Enter the tenant - user already exists, should succeed
    tenanted(@account) do
      assert_no_difference "User.count" do
        get root_url
      end

      assert_response :success
    end
  end
end
