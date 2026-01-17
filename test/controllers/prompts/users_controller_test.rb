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
end
