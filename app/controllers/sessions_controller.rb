# frozen_string_literal: true

# Session controller for Identity authentication.
# Authentication is global (untenanted). User provisioning for accounts
# happens via ensure_account_user when entering tenant scope.
class SessionsController < ApplicationController
  disallow_account_scope
  require_unauthenticated_access only: %i[new create]

  skip_after_action :verify_authorized

  layout "auth"

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_in_path, alert: t("sessions.create.rate_limited") }

  def new
    store_return_to_url
  end

  def create
    if (identity = Identity.authenticate_by(params.permit(:email_address, :password)))
      start_new_session_for(identity)
      redirect_to after_authentication_url, notice: t(".signed_in_successfully")
    else
      flash.now[:alert] = t(".invalid_credentials")
      @mode = :password
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    terminate_session
    redirect_to sign_in_path, notice: t(".signed_out_successfully")
  end
end
