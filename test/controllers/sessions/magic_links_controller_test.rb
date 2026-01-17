# frozen_string_literal: true

require "test_helper"

class Sessions::MagicLinksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:jane)
    @identity = @user.identity
    integration_session.default_url_options[:script_name] = ""
  end

  test "show redirects without pending authentication" do
    get session_magic_link_url

    assert_redirected_to magic_sign_in_path
    assert_equal "Enter your email address to sign in.", flash[:alert]
  end

  test "show displays code entry form with pending authentication" do
    post magic_session_url, params: { email_address: @identity.email_address }
    get session_magic_link_url

    assert_response :success
  end

  test "create with valid code signs in user" do
    magic_link = @identity.send_magic_link

    post magic_session_url, params: { email_address: @identity.email_address }
    post session_magic_link_url, params: { code: magic_link.code }

    assert_response :redirect
    assert_predicate cookies[:session_token], :present?
    assert_not MagicLink.exists?(magic_link.id), "Magic link should be consumed"
  end

  test "create with sign up code redirects to sign up" do
    magic_link = @identity.send_magic_link(for: :sign_up)

    post magic_session_url, params: { email_address: @identity.email_address }
    post session_magic_link_url, params: { code: magic_link.code }

    assert_redirected_to signup_path
    assert_predicate cookies[:session_token], :present?
  end

  test "create with cross-user code fails" do
    other_identity = identities(:john)
    magic_link = other_identity.send_magic_link

    post magic_session_url, params: { email_address: @identity.email_address }
    post session_magic_link_url, params: { code: magic_link.code }

    assert_redirected_to magic_sign_in_path
    assert_nil cookies[:session_token]
  end

  test "create with invalid code shows error" do
    post magic_session_url, params: { email_address: @identity.email_address }
    post session_magic_link_url, params: { code: "INVALID" }

    assert_redirected_to session_magic_link_path
    assert_predicate flash[:alert], :present?
  end

  test "create with expired code fails" do
    magic_link = @identity.send_magic_link
    magic_link.update_column(:expires_at, 1.hour.ago)

    post magic_session_url, params: { email_address: @identity.email_address }
    post session_magic_link_url, params: { code: magic_link.code }

    assert_redirected_to session_magic_link_path
    assert MagicLink.exists?(magic_link.id), "Expired magic link should not be consumed"
  end

  # JSON API tests

  test "create via JSON with valid code" do
    magic_link = @identity.send_magic_link

    post magic_session_url(format: :json), params: { email_address: @identity.email_address }
    post session_magic_link_url(format: :json), params: { code: magic_link.code }

    assert_response :success
    assert_predicate @response.parsed_body["session_token"], :present?
  end

  test "create via JSON without pending_authentication_token" do
    magic_link = @identity.send_magic_link

    post session_magic_link_url(format: :json), params: { code: magic_link.code }

    assert_response :unauthorized
    assert_equal "Enter your email address to sign in.", @response.parsed_body["message"]
  end

  test "create via JSON with invalid code" do
    post magic_session_url(format: :json), params: { email_address: @identity.email_address }
    post session_magic_link_url(format: :json), params: { code: "INVALID" }

    assert_response :unauthorized
    assert_equal "Invalid or expired code. Try another code.", @response.parsed_body["message"]
  end

  test "create via JSON with cross-user code" do
    other_identity = identities(:john)
    magic_link = other_identity.send_magic_link

    post magic_session_url(format: :json), params: { email_address: @identity.email_address }
    post session_magic_link_url(format: :json), params: { code: magic_link.code }

    assert_response :unauthorized
    assert_equal "Something went wrong. Please try again.", @response.parsed_body["message"]
  end

  test "create via JSON with expired pending_authentication_token" do
    magic_link = @identity.send_magic_link

    travel_to 20.minutes.ago do
      post magic_session_url(format: :json), params: { email_address: @identity.email_address }
    end

    post session_magic_link_url(format: :json), params: { code: magic_link.code }

    assert_response :unauthorized
    assert_equal "Enter your email address to sign in.", @response.parsed_body["message"]
  end

  # Tenant context preservation tests

  test "preserves tenant context through magic link flow" do
    account = accounts(:feedbackbin)
    magic_link = @identity.send_magic_link

    # Request magic link from tenant context
    tenanted(account) do
      post magic_session_url, params: { email_address: @identity.email_address }
    end

    # Verify code from untenanted context (session preserves account context)
    untenanted do
      post session_magic_link_url, params: { code: magic_link.code }
    end

    # Should redirect back to the tenant
    assert_redirected_to root_url(script_name: account.slug)
    assert_predicate cookies[:session_token], :present?
  end

  test "creates user for account when signing in via magic link from tenant context" do
    account = accounts(:feedbackbin)
    new_identity = Identity.create!(email_address: "newuser@example.com", password: "password123")
    magic_link = new_identity.send_magic_link

    # Request magic link from tenant context
    tenanted(account) do
      post magic_session_url, params: { email_address: new_identity.email_address }
    end

    # Verify code - should create user for the account
    untenanted do
      assert_difference "account.users.count", 1 do
        post session_magic_link_url, params: { code: magic_link.code }
      end
    end

    # User should be created for the account
    user = account.users.find_by(identity: new_identity)

    assert_not_nil user
    assert_equal :member, user.role.to_sym
  end

  test "does not create duplicate user when signing in via magic link from tenant context" do
    account = accounts(:feedbackbin)
    magic_link = @identity.send_magic_link

    # User already exists in this account
    assert account.users.exists?(identity: @identity)

    # Request magic link from tenant context
    tenanted(account) do
      post magic_session_url, params: { email_address: @identity.email_address }
    end

    # Verify code - should not create duplicate user
    untenanted do
      assert_no_difference "account.users.count" do
        post session_magic_link_url, params: { code: magic_link.code }
      end
    end

    assert_redirected_to root_url(script_name: account.slug)
  end
end
