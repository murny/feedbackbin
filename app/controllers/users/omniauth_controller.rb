# frozen_string_literal: true

module Users
  class OmniauthController < ApplicationController
    disallow_account_scope
    allow_unauthenticated_access only: %i[create failure]

    def create
      return redirect_to root_path, alert: t("something_went_wrong") if auth.nil?

      identity_connected_account = IdentityConnectedAccount.find_by(identity_connected_account_params)

      if identity_connected_account.present?
        handle_previously_connected_identity_account(identity_connected_account)
      elsif authenticated?
        # User is signed in and hasn't connected this account before, so let's connect it
        if Current.identity.identity_connected_accounts.create(identity_connected_account_params)
          redirect_to session_menu_path, notice: t(".connected_successfully", provider: auth.provider)
        else
          # Couldn't connect the account for some reason
          redirect_to session_menu_path, alert: t("something_went_wrong")
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
          if identity_connected_account.identity_id != Current.identity.id
            # User is signed in, but this account is connected to another identity
            redirect_to session_menu_path, alert: t("users.omniauth.create.connected_to_another_account", provider: auth.provider)
          else
            # User is already signed in and has connected this account before
            redirect_to session_menu_path, notice: t("users.omniauth.create.already_connected", provider: auth.provider)
          end
        else
          # Identity has connected this account before, but isn't signed in
          start_new_session_for(identity_connected_account.identity)
          redirect_to after_authentication_url, notice: t("users.omniauth.create.signed_in_successfully")
        end
      end

      def create_identity_and_user
        # We've never seen this identity before, so let's sign them up.
        # OAuth callbacks operate outside account scope (disallow_account_scope),
        # so we extract the account from the OAuth origin URL (where the user came from).
        # Registration via OAuth only allowed within an account context.
        account = account_from_origin

        unless account
          redirect_to signup_path, alert: t("users.omniauth.create.finish_registration")
          return
        end

        Current.account = account

        identity = Identity.new(identity_params)
        identity.identity_connected_accounts.build(identity_connected_account_params)

        user = User.new(user_params.merge(identity: identity))

        if identity.save && user.save
          start_new_session_for(identity)
          redirect_to root_url(script_name: account.slug), notice: t("users.omniauth.create.signed_in_successfully")
        else
          # Identity or User couldn't be saved for some reason, redirect to registration
          redirect_to users_sign_up_path(script_name: account.slug), alert: t("users.omniauth.create.finish_registration")
        end
      end

      def auth
        @auth ||= request.env["omniauth.auth"]
      end

      def identity_params
        {
          email_address: auth.info.email,
          password: SecureRandom.base58(24),
          email_verified_at: Time.current
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

      def account_from_origin
        origin = request.env["omniauth.origin"]
        return nil unless origin

        path = URI.parse(origin).path
        external_account_id, _ = AccountSlug.extract(path)
        return nil unless external_account_id

        Account.find_by(external_account_id: external_account_id)
      rescue URI::InvalidURIError
        nil
      end
  end
end
