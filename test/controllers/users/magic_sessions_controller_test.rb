# frozen_string_literal: true

require "test_helper"

module Users
  class MagicSessionsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:jane)
      @identity = @user.identity
      integration_session.default_url_options[:script_name] = ""
    end

    test "new displays magic sign in form" do
      get magic_sign_in_url

      assert_response :success
    end

    test "create with existing identity sends magic link and redirects" do
      assert_difference("MagicLink.count", 1) do
        assert_enqueued_emails 1 do
          post magic_session_url, params: { email_address: @identity.email_address }
        end
      end

      assert_redirected_to session_magic_link_url
      assert cookies[:pending_authentication_token].present?
    end

    test "create with non-existing email redirects to magic link page" do
      # Should redirect to fake magic link page (doesn't reveal user existence)
      assert_no_difference("MagicLink.count") do
        post magic_session_url, params: { email_address: "nonexistent@example.com" }
      end

      assert_redirected_to session_magic_link_url
      assert cookies[:pending_authentication_token].present?
    end

    test "new redirects authenticated users" do
      sign_in_as(@user)

      get magic_sign_in_url

      assert_response :redirect
    end

    # JSON API tests

    test "create via JSON with existing identity" do
      post magic_session_url(format: :json), params: { email_address: @identity.email_address }

      assert_response :created
      assert @response.parsed_body["pending_authentication_token"].present?
    end

    test "create via JSON with non-existing email" do
      post magic_session_url(format: :json), params: { email_address: "nonexistent@example.com" }

      assert_response :created
      assert @response.parsed_body["pending_authentication_token"].present?
    end
  end
end
