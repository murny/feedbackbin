# frozen_string_literal: true

require "test_helper"

class Users::Settings::ConnectedAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:shane))
  end

  test "should be able to view connected accounts" do
    get users_settings_connected_accounts_url

    assert_response :success
  end

  test "should be able to destroy connected account" do
    user_connected_account = user_connected_accounts(:shane_google)
    delete users_settings_connected_account_url(user_connected_account)

    assert_redirected_to users_settings_connected_accounts_url
    assert_equal "Your connected account has been disconnected successfully.", flash[:notice]
  end
end
