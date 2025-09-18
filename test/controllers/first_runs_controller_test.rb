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
    Organization.create!(name: "FeedbackBin", subdomain: "testfeedbackbin", owner: user, categories_attributes: [ { name: "General" } ])

    get first_run_url

    assert_redirected_to root_url
  end

  test "create with all parameters" do
    assert_difference "Category.count" do
      assert_difference "User.count" do
        assert_difference "Organization.count" do
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
      end
    end

    assert_redirected_to root_url
    assert parsed_cookies.signed[:session_id]

    user = User.last

    assert_equal "new@feedbackbin.com", user.email_address

    organization = Organization.last

    assert_equal "Test Organization", organization.name
    assert_equal "Custom Category", organization.categories.first.name
    assert_equal user, organization.owner
  end

  # TODO: This test is taking an insane amount of time to run?
  #
  # test "create fails with missing information" do
  #   assert_no_difference "User.count" do
  #     assert_no_difference "Organization.count" do
  #       post first_run_url, params: {
  #         first_run: {
  #           email_address: "new@feedbackbin.com",
  #           password: "secret123456",
  #           organization_subdomain: "myorg"
  #         }
  #       }
  #     end
  #   end

  #   assert_response :unprocessable_entity
  # end
end
