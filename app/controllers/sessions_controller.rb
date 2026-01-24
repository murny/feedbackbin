# frozen_string_literal: true

# Session controller for Identity authentication.
# Works in both tenant and non-tenant contexts:
# - Non-tenant: FeedbackBin branding, redirects to account menu after sign-in
# - Tenant: Org branding with navbar/footer, redirects to tenant root after sign-in
class SessionsController < ApplicationController
  include AuthLayout

  skip_before_action :require_account
  require_unauthenticated_access only: %i[new create]

  skip_after_action :verify_authorized

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
