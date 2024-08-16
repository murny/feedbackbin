# frozen_string_literal: true

require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get sign_up_url

    assert_response :success
  end

  test "should sign up" do
    assert_difference("User.count") do
      post registrations_url, params: {name: "Jane Doe", email_address: "new@example.com", password: "123456", password_confirmation: "123456"}
    end

    assert_redirected_to root_url
  end
end
