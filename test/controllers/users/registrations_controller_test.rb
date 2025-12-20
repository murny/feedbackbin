# frozen_string_literal: true

require "test_helper"

module Users
  class RegistrationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      # Registration controller uses disallow_account_scope - test without account prefix
      integration_session.default_url_options[:script_name] = ""
    end

    test "should get new" do
      get sign_up_url

      assert_response :success
    end

    test "should sign up" do
      assert_difference [ "User.count", "Identity.count" ] do
        post users_registrations_url, params: { user: {
          name: "New User",
          email_address: "new_user@example.com",
          password: "password123456",
          password_confirmation: "password123456"
        } }
      end

      assert_enqueued_email_with IdentityMailer, :email_verification, args: [ Identity.last ]

      # After signup, redirects to user's first account
      user = User.last

      assert_redirected_to root_url(script_name: user.account.slug)
      assert_equal "Welcome! You have signed up successfully.", flash[:notice]
    end

    test "should not sign up with invalid data" do
      assert_no_difference [ "User.count", "Identity.count" ] do
        assert_no_enqueued_emails do
          post users_registrations_url, params: { user: {
            name: "Jane Doe",
            email_address: "bad_email",
            password: "password123456",
            password_confirmation: "password123456"
          } }
        end
      end

      assert_response :unprocessable_entity
    end
  end
end
