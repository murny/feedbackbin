# frozen_string_literal: true

# Untenanted session controller for global Identity authentication.
# After sign in, redirects to session menu to pick which account to access.
# For tenanted sign in (within a specific account), see Users::SessionsController.
class SessionsController < ApplicationController
  layout "auth"

  disallow_account_scope
  require_unauthenticated_access only: %i[new create]
  skip_after_action :verify_authorized

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_in_path, alert: t("sessions.create.rate_limited") }

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
