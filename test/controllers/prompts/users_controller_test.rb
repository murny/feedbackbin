# frozen_string_literal: true

require "test_helper"

class Prompts::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:shane))
  end

  test "should get index" do
    get prompts_users_url

    assert_response :success
  end

  test "should return users as lexxy prompt items" do
    get prompts_users_url

    assert_select "lexxy-prompt-item", minimum: 1
  end

  test "returns only Current.account users" do
    in_account_user = users(:jane)
    out_of_account_user = users(:acme_admin)

    get prompts_users_url

    assert_response :success
    assert_includes response.body, in_account_user.name
    assert_not_includes response.body, out_of_account_user.name
  end

  test "excludes inactive users" do
    inactive_user = users(:john)
    inactive_user.update_column(:active, false)

    get prompts_users_url

    assert_response :success
    assert_not_includes response.body, inactive_user.name
  end
end
