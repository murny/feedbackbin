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
  end
end
