# frozen_string_literal: true

require "test_helper"

module ApplicationCable
  class ConnectionTest < ActionCable::Connection::TestCase
    setup do
      # Use non-default account to verify Current.account is set correctly
      @account = accounts(:acme)
      @session = sessions(:acme_admin_session)
    end

    test "connects with valid session and account info" do
      cookies.signed[:session_token] = @session.signed_id

      connect "/cable", env: { "feedbackbin.external_account_id" => @account.external_account_id }

      assert_equal users(:acme_admin), connection.current_user
      assert_equal @account, Current.account
    end

    test "rejects with invalid session token" do
      cookies.signed[:session_token] = "invalid-session-id"

      assert_reject_connection do
        connect "/cable", env: { "feedbackbin.external_account_id" => @account.external_account_id }
      end
    end

    test "rejects when account does not exist" do
      cookies.signed[:session_token] = @session.signed_id

      assert_reject_connection do
        connect "/cable", env: { "feedbackbin.external_account_id" => -1 }
      end
    end
  end
end
