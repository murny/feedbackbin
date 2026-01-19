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

  # Return URL preservation tests

  test "preserves return URL through magic link flow" do
    magic_link = @identity.send_magic_link

    # Simulate coming from a protected page by setting return_to
    untenanted do
      post magic_session_url, params: { email_address: @identity.email_address }
      post session_magic_link_url, params: { code: magic_link.code }
    end

    # Should redirect to session menu (default for untenanted)
    assert_redirected_to session_menu_url(script_name: nil)
    assert_predicate cookies[:session_token], :present?
  end

  test "creates user for account when entering tenant after magic link sign in" do
    account = accounts(:feedbackbin)
    new_identity = Identity.create!(email_address: "newuser@example.com", password: "password123")
    magic_link = new_identity.send_magic_link

    # Sign in via magic link (untenanted)
    untenanted do
      post magic_session_url, params: { email_address: new_identity.email_address }
      post session_magic_link_url, params: { code: magic_link.code }
    end

    # Now enter the tenant - should create user via ensure_account_user
    tenanted(account) do
      assert_difference "account.users.count", 1 do
        get root_url
      end
    end

    # User should be created for the account
    user = account.users.find_by(identity: new_identity)

    assert_not_nil user
    assert_equal :member, user.role.to_sym
  end

  test "does not create duplicate user when entering tenant after magic link sign in" do
    account = accounts(:feedbackbin)
    magic_link = @identity.send_magic_link

    # User already exists in this account
    assert account.users.exists?(identity: @identity)

    # Sign in via magic link (untenanted)
    untenanted do
      post magic_session_url, params: { email_address: @identity.email_address }
      post session_magic_link_url, params: { code: magic_link.code }
    end

    # Enter the tenant - should not create duplicate user
    tenanted(account) do
      assert_no_difference "account.users.count" do
        get root_url
      end
    end

    assert_response :success
  end
end
