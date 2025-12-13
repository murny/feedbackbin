# frozen_string_literal: true

module Users
  class OmniauthController < ApplicationController
    allow_unauthenticated_access only: %i[create failure]
    skip_after_action :verify_authorized

    def create
      return redirect_to root_path, alert: t("something_went_wrong") if auth.nil?

      connected_account = IdentityConnectedAccount.find_by(connected_account_params)

      if connected_account.present?
        handle_previously_connected_account(connected_account)
      elsif authenticated?
        # User is signed in, connect this OAuth to their identity
        connect_to_current_identity
      elsif (identity = Identity.find_by(email_address: auth.info.email))
        # Identity exists, connect OAuth and sign in
        connect_and_sign_in(identity)
      else
        # New identity via OAuth
        create_identity_from_oauth
      end
    end

    def failure
      redirect_to root_path, alert: t("something_went_wrong")
    end

    private

      def handle_previously_connected_account(connected_account)
        if authenticated?
          if connected_account.identity_id != Current.identity.id
            redirect_to root_path, alert: t("users.omniauth.create.connected_to_another_account", provider: auth.provider)
          else
            redirect_to user_settings_account_path, notice: t("users.omniauth.create.already_connected", provider: auth.provider)
          end
        else
          identity = connected_account.identity
          if identity.accounts.any?
            start_new_session_for(identity)
            redirect_to after_authentication_url, notice: t("users.omniauth.create.signed_in_successfully")
          else
            start_new_session_for(identity)
            redirect_to new_account_path, notice: t("users.omniauth.handle_previously_connected_account.create_or_join_account")
          end
        end
      end

      def connect_to_current_identity
        if Current.identity.connected_accounts.create(connected_account_params)
          redirect_to user_settings_account_path, notice: t("users.omniauth.connect_to_current_identity.connected_successfully", provider: auth.provider)
        else
          redirect_to user_settings_account_path, alert: t("something_went_wrong")
        end
      end

      def connect_and_sign_in(identity)
        if identity.connected_accounts.create(connected_account_params)
          start_new_session_for(identity)
          redirect_to after_authentication_url, notice: t("users.omniauth.connect_and_sign_in.signed_in_successfully")
        else
          redirect_to root_path, alert: t("something_went_wrong")
        end
      end

      def create_identity_from_oauth
        identity = Identity.new(identity_params)
        identity.connected_accounts.build(connected_account_params)

        if identity.save
          start_new_session_for(identity)
          # New OAuth user needs to create/join an account
          redirect_to new_account_path, notice: t("users.omniauth.create_identity_from_oauth.create_or_join_account")
        else
          redirect_to sign_up_path(identity: {
            email_address: identity.email_address
          }), alert: t("users.omniauth.create.finish_registration")
        end
      end

      def auth
        @auth ||= request.env["omniauth.auth"]
      end

      def identity_params
        {
          email_address: auth.info.email,
          password: SecureRandom.base58
        }
      end

      def connected_account_params
        {
          provider_name: auth.provider,
          provider_uid: auth.uid
        }
      end
  end
end
