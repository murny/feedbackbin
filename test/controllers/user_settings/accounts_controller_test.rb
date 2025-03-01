# frozen_string_literal: true

require "test_helper"

module UserSettings
  class AccountsControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as(users(:one))
    end

    test "should get show" do
      get user_settings_account_url

      assert_response :success
    end

    test "should be able to update account" do
      patch user_settings_account_url, params: { user: { username: "new_username" } }

      assert_redirected_to user_settings_account_url
      assert_equal "Your account has been updated.", flash[:notice]
    end
  end
end
