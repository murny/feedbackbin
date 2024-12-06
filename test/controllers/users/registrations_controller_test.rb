# frozen_string_literal: true

require "test_helper"

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sign_up_url

    assert_response :success
  end

  test "should sign up" do
    assert_difference("User.count") do
      post users_registrations_url, params: {user: {
        username: "new_user",
        name: "New user",
        email_address: "new_user@example.com",
        password: "password123456",
        password_confirmation: "password123456"
      }}
    end

    assert_enqueued_email_with UserMailer, :email_verification, args: [User.last]

    assert_redirected_to root_url
    assert_equal "Welcome! You have signed up successfully.", flash[:notice]
  end

  test "should not sign up with invalid data" do
    assert_no_difference("User.count") do
      assert_no_enqueued_emails do
        post users_registrations_url, params: {user: {
          name: "Jane Doe",
          email_address: "bad_email",
          password: "password123456",
          password_confirmation: "password123456"
        }}
      end
    end

    assert_response :unprocessable_entity
  end
end
