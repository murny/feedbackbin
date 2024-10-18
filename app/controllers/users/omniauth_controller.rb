# frozen_string_literal: true

module Users
  class OmniauthController < ApplicationController
    allow_unauthenticated_access only: %i[create failure]

    def create
      redirect_to root_path, alert: t("something_went_wrong") if auth.nil?

      # Find or create an identity here
      user_identity = UserIdentity.find_or_create_by(uid: auth.uid, provider: auth.provider)

      user = get_omniauth_user(auth, user_identity)

      # 1. Account has already been connected before
      # 2. User is signed in, but hasn't connected this account before
      # 3. We haven't seen this account before, but we have an existing user with a matching email
      # 4. We've never seen this user before, so let's sign them up

      if user.persisted?
        start_new_session_for(user)
        redirect_to after_authentication_url, notice: t(".signed_in_successfully")
      else
        # User couldn't be saved for some reason, so let's redirect them to the registration page
        # Store the attributes in the session to prefill the form
        session["omniauth.user_attributes"] = user.attributes
        redirect_to new_user_registration_path, alert: t(".finish_registration")
      end
    end

    def failure
      redirect_to root_path, alert: t("something_went_wrong")
    end

    private

    def auth
      @auth ||= request.env["omniauth.auth"]
    end

    def user_identity
      @user_identity ||= UserIdentity.find_by(user_identity_params)
    end

    def user_params
    end

    def user_identity_params
      {
        provider_name: auth.provider,
        provider_uid: auth.uid
      }
    end

    def get_omniauth_user(auth, user_identity)
      return Current.user if Current.user && user_identity.user_id == Current.user.id

      user = Current.user || user_identity.user || User.find_by(email: auth.info.email)

      if user.nil?
        # We've never seen this user before, so let's sign them up
        user = User.create(
          email_address: auth.info.email,
          password: SecureRandom.base58,
          name: name_creator(auth.info),
          username: username_creator(auth.info.nickname || auth.info.name),
          email_verified: true
        )
      end

      if user_identity.user_id.blank? && user.persisted?
        # User hasn't connected this account before, so let's do this now
        user_identity.user = user
        user_identity.save
      end

      user
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
      # limit name to max username length
      username = username[0, User::MAX_USERNAME_LENGTH]
      # sanitize, remove any non alphanumeric/underscore characters
      username.gsub!(/[^0-9a-z_]/i, "")

      username = "user_1234567890" if username.blank?

      # check if username avaiable?
      while User.exists?(username: username)
        # username is currently being used, so just generate a random username of "user_<random_number>" and try again
        username = "user_#{SecureRandom.hex[1..10]}"
      end

      username
    end
  end
end
