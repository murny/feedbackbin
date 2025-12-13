# frozen_string_literal: true

require "test_helper"

module Users
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    test "should get new" do
      get sign_up_url

      assert_response :success
    end

    test "should sign up" do
      assert_difference("Identity.count") do
        post users_registrations_url, params: { identity: {
          email_address: "new_user@example.com",
          password: "password123456",
          password_confirmation: "password123456"
        }, user: { name: "New User" } }
      end

      assert_enqueued_email_with IdentityMailer, :email_verification, args: [ Identity.last ]

      assert_redirected_to root_url
      assert_equal "Welcome! You have signed up successfully.", flash[:notice]
    end

    test "should not sign up with invalid data" do
      assert_no_difference("Identity.count") do
        assert_no_enqueued_emails do
          post users_registrations_url, params: { identity: {
            email_address: "bad_email",
            password: "password123456",
            password_confirmation: "password123456"
          }, user: { name: "Jane Doe" } }
        end
      end

      assert_response :unprocessable_entity
    end
  end
end
