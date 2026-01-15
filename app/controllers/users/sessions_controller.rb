# frozen_string_literal: true

module Users
  class SessionsController < ApplicationController
    disallow_account_scope except: :destroy
    skip_before_action :require_account, only: :destroy
    require_unauthenticated_access only: %i[new create]
    skip_after_action :verify_authorized

    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_in_path, alert: t("users.sessions.create.rate_limited") }

    def new
    end

    def create
      if (identity = Identity.authenticate_by(params.permit(:email_address, :password)))
        if identity.users.active.none?
          redirect_to sign_in_path, alert: t(".account_deactivated")
        else
          start_new_session_for(identity)
          redirect_to after_authentication_url, notice: t(".signed_in_successfully")
        end
      else
        redirect_to sign_in_path, alert: t(".invalid_credentials")
      end
    end

    def destroy
      terminate_session
      redirect_to sign_in_path, notice: t(".signed_out_successfully")
    end
  end
end
