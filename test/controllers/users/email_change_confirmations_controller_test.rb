# frozen_string_literal: true

require "test_helper"

module Users
  class EmailChangeConfirmationsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @identity = identities(:jane)
      integration_session.default_url_options[:script_name] = ""
    end

    test "valid token changes email address and starts new session" do
      new_email = "jane.new@example.com"
      token = generate_email_change_token(@identity, new_email)

      get users_email_change_confirmation_url(token: token)

      assert_equal new_email, @identity.reload.email_address
      assert_redirected_to session_menu_url
      assert_equal I18n.t("users.email_change_confirmations.show.email_changed_successfully"), flash[:notice]
    end

    test "invalid token redirects to sign in with alert" do
      get users_email_change_confirmation_url(token: "invalid-token")

      assert_redirected_to sign_in_url
      assert_equal I18n.t("users.email_change_confirmations.invalid_or_expired_token"), flash[:alert]
    end

    test "expired token redirects to sign in with alert" do
      new_email = "jane.expired@example.com"
      token = travel_to(1.hour.ago) do
        generate_email_change_token(@identity, new_email)
      end

      get users_email_change_confirmation_url(token: token)

      assert_redirected_to sign_in_url
      assert_equal I18n.t("users.email_change_confirmations.invalid_or_expired_token"), flash[:alert]
    end

    test "valid token terminates the current session before creating a new one" do
      sign_in_as(@identity.users.first)
      integration_session.default_url_options[:script_name] = ""
      old_session = Current.session

      new_email = "jane.newsession@example.com"
      token = generate_email_change_token(@identity, new_email)

      get users_email_change_confirmation_url(token: token)

      assert_redirected_to session_menu_url
      assert_not Session.exists?(old_session.id)
    end

    private

      def generate_email_change_token(identity, new_email)
        identity.to_sgid(
          for: Identity::EmailAddressChangeable::EMAIL_CHANGE_TOKEN_PURPOSE,
          expires_in: Identity::EmailAddressChangeable::EMAIL_CHANGE_TOKEN_EXPIRATION,
          old_email_address: identity.email_address,
          new_email_address: new_email
        ).to_s
      end
  end
end
