# frozen_string_literal: true

require "test_helper"

class FirstRunsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Organization.destroy_all
    PostStatus.destroy_all
  end

  test "new is permitted when no organizations exist" do
    get first_run_url

    assert_response :success
  end

  test "new is not permitted when organization exist" do
    User.create!(
      name: "Test User",
      email_address: "new@feedbackbin.com",
      password: "secret123456",
      role: :owner
    )
    PostStatus.create!(name: "Open", color: "#3b82f6", position: 1)
    Organization.create!(
      name: "FeedbackBin",
      default_post_status: PostStatus.first
    )

    get first_run_url

    assert_redirected_to root_url
  end

  test "create with all parameters" do
    assert_difference [ "User.count", "Organization.count", "Category.count" ], 1 do
      assert_difference "PostStatus.count", 5 do
        post first_run_url, params: {
          first_run: {
            name: "New Person",
            email_address: "new@feedbackbin.com",
            password: "secret123456",
            organization_name: "Test Organization",
            category_name: "Custom Category",
            category_color: "#3b82f6"
          }
        }
      end
    end

    assert_redirected_to root_url

    user = User.last
    organization = Organization.last

    assert_equal user.sessions.last.id, parsed_cookies.signed[:session_id]
    assert_equal "new@feedbackbin.com", user.email_address

    assert_equal "Test Organization", organization.name
    assert_equal "Custom Category", Category.last.name

    assert_predicate user, :owner?

    assert_equal PostStatus.default, organization.default_post_status
  end

  test "create fails with missing information" do
    assert_no_difference [ "User.count", "Organization.count", "Category.count", "PostStatus.count" ] do
      post first_run_url, params: {
        first_run: {
          email_address: "new@feedbackbin.com",
          password: "secret123456"
          # Missing: name, organization_name, category_name, category_color (required fields)
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
