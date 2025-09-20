# frozen_string_literal: true

require "test_helper"

class FirstRunsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Organization.destroy_all
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
    Organization.create!(name: "FeedbackBin", subdomain: "testfeedbackbin", owner: user)

    get first_run_url

    assert_redirected_to root_url
  end

  test "create with all parameters" do
    assert_difference [ "User.count", "Organization.count", "Category.count", "Membership.count" ] do
      post first_run_url, params: {
        first_run: {
          username: "new_person",
          email_address: "new@feedbackbin.com",
          password: "secret123456",
          name: "New Person",
          organization_name: "Test Organization",
          organization_subdomain: "testorg",
          category_name: "Custom Category"
        }
      }
    end

    assert_redirected_to root_url

    user = User.last

    assert_equal user.sessions.last.id, parsed_cookies.signed[:session_id]
    assert_equal "new@feedbackbin.com", user.email_address

    assert_equal "Test Organization", Organization.last.name
    assert_equal "Custom Category", Category.last.name

    assert_equal user, Organization.last.owner
  end

  test "create fails with missing information" do
    assert_no_difference [ "User.count", "Organization.count", "Category.count", "Membership.count" ] do
      post first_run_url, params: {
        first_run: {
          email_address: "new@feedbackbin.com",
          password: "secret123456",
          organization_subdomain: "myorg"
          # Missing: username, organization_name (required fields)
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
