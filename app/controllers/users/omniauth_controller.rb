# frozen_string_literal: true

module Users
  class OmniauthController < ApplicationController
    allow_unauthenticated_access only: %i[create failure]

    # TODO: This action is doing double duty
    # it's working as a callback for OAuth and as a controller action for connecting accounts when signed in
    # Logic for connecting accounts when signed in could go to a separate controller action?
    def create
      redirect_to root_path, alert: t("something_went_wrong") if auth.nil?

      # Find or create an identity here
      user_identity = UserIdentity.find_by(user_identity_params)

      if user_identity.present?
        handle_previously_connected_user_identity(user_identity)
      elsif authenticated?
        # User is signed in and hasn't connected this account before, so let's connect it
        if Current.user.user_identities.create(user_identity_params)
          redirect_to users_settings_connected_accounts_path, notice: t(".connected_successfully", provider: auth.provider)
        else
          # Couldn't connect the account for some reason
          redirect_to users_settings_connected_accounts_path, alert: t("something_went_wrong")
        end

      elsif (user = User.find_by(email_address: auth.info.email))
        # User exists but hasn't connected this account before, so let's connect it
        if user.user_identities.create(user_identity_params)
          start_new_session_for(user)
          redirect_to after_authentication_url, notice: t(".signed_in_successfully")
        else
          # Couldn't connect the account for some reason
          redirect_to root_path, alert: t("something_went_wrong")
        end
      else
        create_user
      end
    end

    def failure
      redirect_to root_path, alert: t("something_went_wrong")
    end

    private

    def handle_previously_connected_user_identity(user_identity)
      # Account has already been connected before
      if authenticated?
        if user_identity.user_id != Current.user.id
          # User is signed in, but this account is connected to another user
          redirect_to root_path, alert: t(".connected_to_another_account", provider: auth.provider)
        else
          # User is already signed in and has connected this account before
          redirect_to users_settings_connected_accounts_path, notice: t(".already_connected", provider: auth.provider)
        end
      else
        # User has connected this account before, but isn't signed in
        start_new_session_for(user_identity.user)
        redirect_to after_authentication_url, notice: t(".signed_in_successfully")
      end
    end

    def create_user
      # We've never seen this user before, so let's sign them up
      user = User.new(user_params)
      user.user_identities.build(user_identity_params)

      if user.save
        start_new_session_for(user)
        redirect_to after_authentication_url, notice: t(".signed_in_successfully")
      else
        # User couldn't be saved for some reason, so let's redirect them to the registration page
        # Store the user attributes in the query string to prefill the form
        redirect_to new_user_registration_path(user: user.attributes), alert: t(".finish_registration")
      end
    end

    def auth
      @auth ||= request.env["omniauth.auth"]
    end

    def user_params
      name = name_creator(auth.info)

      {
        email_address: auth.info.email,
        name: name,
        password: SecureRandom.base58,
        username: username_creator(auth.info.nickname || name),
        email_verified: true
      }
    end

    def user_identity_params
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

    # Given a username from OAuth, generate a unique username for our application
    def username_creator(username = nil)
      username = "user_#{SecureRandom.hex[1..14]}" if username.blank?

      # sanitize, remove any non alphanumeric/underscore characters
      username.gsub!(/[^0-9a-z_]/i, "")
      # limit name to max username length
      username = username[0, User::MAX_USERNAME_LENGTH]

      # check if username avaiable?
      while User.exists?(username: username)
        # username is currently being used, so just generate a random username of "user_<random_number>" and try again
        username = "user_#{SecureRandom.hex[1..14]}"
      end

      username
    end
  end
end
