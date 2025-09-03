# frozen_string_literal: true

require "test_helper"

class FirstRunsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Organization.destroy_all
    Category.destroy_all
    User.destroy_all
  end

  test "new is permitted when no other users exit" do
    get first_run_url

    assert_response :success
  end

  test "new is not permitted when organization exist" do
    user = User.create!(
      username: "test_user",
      email_address: "new@feedbackbin.com",
      password: "secret123456"
    )
    Organization.create!(name: "FeedbackBin", owner: user, categories_attributes: [ { name: "General" } ])

    get first_run_url

    assert_redirected_to root_url
  end

  test "create" do
    assert_difference "Category.count" do
      assert_difference "User.count" do
        post first_run_url, params: {
          organization: { name: "FeedbackBin" },
          user: {
            username: "new_person",
            email_address: "new@feedbackbin.com",
            password: "secret123456"
          }
        }
      end
    end

    assert_redirected_to root_url
    assert parsed_cookies.signed[:session_id]
  end
end
