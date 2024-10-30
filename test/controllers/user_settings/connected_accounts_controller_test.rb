# frozen_string_literal: true

require "test_helper"

class UserSettings::ConnectedAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in(users(:shane))
  end

  test "should be able to destroy connected account" do
    user_connected_account = user_connected_accounts(:shane_google)
    delete user_settings_connected_account_url(user_connected_account)

    assert_redirected_to user_settings_account_url
    assert_equal "Your connected account has been disconnected successfully.", flash[:notice]
  end
end
