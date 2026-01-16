# frozen_string_literal: true

module Users
  # Tenanted session controller for signing in within a specific account context.
  # Shows account-branded sign in page and creates/associates User with the account.
  # For global/untenanted sign in, see SessionsController.
  class SessionsController < ApplicationController
    allow_unauthenticated_access
    before_action :redirect_authenticated_user, only: %i[new create]
    skip_after_action :verify_authorized

    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to users_sign_in_path, alert: t("users.sessions.create.rate_limited") }

    def new
    end

    def create
      if (identity = Identity.authenticate_by(params.permit(:email_address, :password)))
        handle_successful_authentication(identity)
      else
        redirect_to users_sign_in_path, alert: t(".invalid_credentials")
      end
    end

    private

      def handle_successful_authentication(identity)
        # Find user for this account (includes both active and inactive)
        user = Current.account.users.find_by(identity: identity)

        if user.nil?
          # Identity exists but no user for this account - create one
          user = create_user_for_account(identity)
        elsif !user.active?
          redirect_to users_sign_in_path, alert: t("users.sessions.create.account_deactivated")
          return
        end

        start_new_session_for(identity)
        redirect_to after_authentication_url, notice: t("users.sessions.create.signed_in_successfully")
      end

      def create_user_for_account(identity)
        identity.users.create!(
          account: Current.account,
          name: identity.email_address.split("@").first.titleize,
          role: :member
        )
      end

      def redirect_authenticated_user
        redirect_to root_path if authenticated?
      end

      def after_authentication_url
        session.delete(:return_to_after_authenticating) || root_path
      end
  end
end
