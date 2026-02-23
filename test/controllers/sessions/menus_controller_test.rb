# frozen_string_literal: true

require "test_helper"

module Sessions
  class MenusControllerTest < ActionDispatch::IntegrationTest
    setup do
      integration_session.default_url_options[:script_name] = ""
    end

    test "unauthenticated user is redirected to sign in" do
      get session_menu_url

      assert_redirected_to sign_in_url
    end

    test "user with multiple accounts sees the account picker" do
      identity = identities(:shane)
      second_account = Account.create!(name: "Second Account")
      identity.users.create!(account: second_account, name: "Shane 2", role: :member)

      sign_in_as(identity.users.first)
      integration_session.default_url_options[:script_name] = ""

      get session_menu_url

      assert_response :success
    end

    test "user with a single account is redirected to that account root" do
      identity = identities(:jane)

      sign_in_as(identity.users.first)
      integration_session.default_url_options[:script_name] = ""

      get session_menu_url

      jane_account = identity.accounts.sole
      assert_redirected_to root_url(script_name: jane_account.slug)
    end
  end
end
