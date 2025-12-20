# frozen_string_literal: true

module Users
  class OmniauthController < ApplicationController
    disallow_account_scope
    allow_unauthenticated_access only: %i[create failure]
    skip_after_action :verify_authorized

    def create
      return redirect_to root_path, alert: t("something_went_wrong") if auth.nil?

      identity_connected_account = IdentityConnectedAccount.find_by(identity_connected_account_params)

      if identity_connected_account.present?
        handle_previously_connected_identity_account(identity_connected_account)
      elsif authenticated?
        # User is signed in and hasn't connected this account before, so let's connect it
        user = Current.identity.users.first
        if Current.identity.identity_connected_accounts.create(identity_connected_account_params)
          redirect_to user_settings_account_url(script_name: user&.account&.slug), notice: t(".connected_successfully", provider: auth.provider)
        else
          # Couldn't connect the account for some reason
          redirect_to user_settings_account_url(script_name: user&.account&.slug), alert: t("something_went_wrong")
        end

      elsif (identity = Identity.find_by(email_address: auth.info.email))
        # Identity exists but hasn't connected this account before, so let's connect it
        if identity.identity_connected_accounts.create(identity_connected_account_params)
          start_new_session_for(identity)
          redirect_to after_authentication_url, notice: t(".signed_in_successfully")
        else
          # Couldn't connect the account for some reason
          redirect_to root_path, alert: t("something_went_wrong")
        end
      else
        create_identity_and_user
      end
    end

    def failure
      redirect_to root_path, alert: t("something_went_wrong")
    end

    private

      def handle_previously_connected_identity_account(identity_connected_account)
        # Account has already been connected before
        if authenticated?
          user = Current.identity.users.first
          if identity_connected_account.identity_id != Current.identity.id
            # User is signed in, but this account is connected to another identity
            redirect_to root_url(script_name: user&.account&.slug), alert: t("users.omniauth.create.connected_to_another_account", provider: auth.provider)
          else
            # User is already signed in and has connected this account before
            redirect_to user_settings_account_url(script_name: user&.account&.slug), notice: t("users.omniauth.create.already_connected", provider: auth.provider)
          end
        else
          # Identity has connected this account before, but isn't signed in
          start_new_session_for(identity_connected_account.identity)
          redirect_to after_authentication_url, notice: t("users.omniauth.create.signed_in_successfully")
        end
      end

      def create_identity_and_user
        # We've never seen this identity before, so let's sign them up
        # Set account context for self-registration (use first account)
        Current.account = Account.first

        identity = Identity.new(identity_params)
        identity.identity_connected_accounts.build(identity_connected_account_params)

        user = User.new(user_params.merge(identity: identity))

        if identity.save && user.save
          start_new_session_for(identity)
          redirect_to after_authentication_url, notice: t("users.omniauth.create.signed_in_successfully")
        else
          # Identity or User couldn't be saved for some reason, redirect to registration
          redirect_to sign_up_path(user: {
            email_address: auth.info.email,
            name: name_creator(auth.info)
          }), alert: t("users.omniauth.create.finish_registration")
        end
      end

      def auth
        @auth ||= request.env["omniauth.auth"]
      end

      def identity_params
        {
          email_address: auth.info.email,
          password: SecureRandom.base58(24),
          email_verified: true
        }
      end

      def user_params
        {
          name: name_creator(auth.info),
          role: :member
        }
      end

      def identity_connected_account_params
        {
          provider_name: auth.provider,
          provider_uid: auth.uid
        }
      end

      def name_creator(auth_info)
        if auth_info.first_name && auth_info.last_name
          "#{auth_info.first_name} #{auth_info.last_name}"
        else
          auth_info.name
        end
      end
  end
end
