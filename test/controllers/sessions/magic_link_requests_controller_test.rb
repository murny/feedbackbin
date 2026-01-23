# frozen_string_literal: true

require "test_helper"

module Sessions
  class MagicLinkRequestsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:jane)
      @identity = @user.identity
      integration_session.default_url_options[:script_name] = ""
    end

    test "create with existing identity sends magic link and redirects" do
      assert_difference("MagicLink.count", 1) do
        assert_enqueued_emails 1 do
          post session_magic_link_requests_url, params: { email_address: @identity.email_address }
        end
      end

      assert_redirected_to session_magic_link_url
      assert_predicate cookies[:pending_authentication_token], :present?
    end

    test "create with non-existing email redirects to magic link page" do
      assert_no_difference("MagicLink.count") do
        post session_magic_link_requests_url, params: { email_address: "nonexistent@example.com" }
      end

      assert_redirected_to session_magic_link_url
      assert_predicate cookies[:pending_authentication_token], :present?
    end

    test "create via JSON with existing identity" do
      post session_magic_link_requests_url(format: :json), params: { email_address: @identity.email_address }

      assert_response :created
      assert_predicate @response.parsed_body["pending_authentication_token"], :present?
    end

    test "create via JSON with non-existing email" do
      post session_magic_link_requests_url(format: :json), params: { email_address: "nonexistent@example.com" }

      assert_response :created
      assert_predicate @response.parsed_body["pending_authentication_token"], :present?
    end
  end
end
