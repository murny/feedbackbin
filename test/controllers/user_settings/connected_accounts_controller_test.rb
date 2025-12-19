# frozen_string_literal: true

require "test_helper"

module UserSettings
  class ConnectedAccountsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:jane)
      sign_in_as(@user)
    end

    test "should be able to destroy connected account" do
      identity_connected_account = @user.identity.identity_connected_accounts.first
      delete user_settings_connected_account_url(identity_connected_account)

      assert_redirected_to user_settings_account_url
      assert_equal "Your connected account has been disconnected successfully.", flash[:notice]
    end
  end
end
