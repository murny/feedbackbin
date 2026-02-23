# frozen_string_literal: true

require "test_helper"

module Staff
  class AccountsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @staff_user = users(:shane)
      @account = accounts(:feedbackbin)
    end

    test "staff user can view accounts index" do
      sign_in_as @staff_user

      get staff_accounts_url

      assert_response :success
    end

    test "non-staff user cannot access accounts index" do
      sign_in_as users(:jane)

      get staff_accounts_url

      assert_response :not_found
    end

    test "unauthenticated user cannot access accounts index" do
      get staff_accounts_url

      assert_response :not_found
    end

    test "staff user can view a specific account" do
      sign_in_as @staff_user

      get staff_account_url(@account)

      assert_response :success
    end

    test "non-staff user cannot view a specific account" do
      sign_in_as users(:jane)

      get staff_account_url(@account)

      assert_response :not_found
    end

    test "accounts index supports search" do
      sign_in_as @staff_user

      get staff_accounts_url, params: { search: @account.name }

      assert_response :success
    end
  end
end
