# frozen_string_literal: true

module Users
  class SessionsController < ApplicationController
    allow_unauthenticated_access only: %i[new create]
    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_in_path, alert: t("users.sessions.create.rate_limited") }

    before_action :ensure_user_exists, only: :new

    def new
    end

    def create
      if (user = User.authenticate_by(params.permit(:email_address, :password)))
        start_new_session_for user
        redirect_to after_authentication_url, notice: t(".signed_in_successfully")
      else
        redirect_to sign_in_path, alert: t(".invalid_credentials")
      end
    end

    def destroy
      terminate_session
      redirect_back(fallback_location: sign_in_path, notice: t(".signed_out_successfully"))
    end

    private

    def ensure_user_exists
      redirect_to first_run_path if User.none?
    end
  end
end
