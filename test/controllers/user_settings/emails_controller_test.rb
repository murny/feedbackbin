# frozen_string_literal: true

require "test_helper"

module UserSettings
  class EmailsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:jane)
      @identity = @user.identity
      sign_in_as(@user)
    end

    test "should send verification email when updating email" do
      original_email = @identity.email_address

      assert_enqueued_emails 1 do
        patch user_settings_email_url, params: { identity: { email_address: "new_email@example.com", password_challenge: "secret123456" } }
      end

      assert_redirected_to user_settings_account_url
      assert_equal "We've sent a verification link to your new email address. Please check your inbox.", flash[:notice]

      # Email should not be changed yet
      assert_equal original_email, @identity.reload.email_address
    end

    test "should not allow changing to an already taken email" do
      existing_identity = identities(:shane)

      patch user_settings_email_url, params: { identity: { email_address: existing_identity.email_address, password_challenge: "secret123456" } }

      assert_response :unprocessable_entity
    end

    test "should not be able to update email with invalid password" do
      patch user_settings_email_url, params: { identity: { email_address: "new_email@example.com", password_challenge: "invalid" } }

      assert_response :unprocessable_entity
    end

    test "if email has not changed" do
      patch user_settings_email_url, params: { identity: { email_address: @identity.email_address, password_challenge: "secret123456" } }

      assert_redirected_to user_settings_account_url
      assert_equal "You provided the same email address, nothing has changed.", flash[:notice]
    end
  end
end
