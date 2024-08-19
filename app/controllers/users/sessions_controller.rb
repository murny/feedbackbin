# frozen_string_literal: true

class Users::SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_in_url, alert: t("users.sessions.create.rate_limited") }

  def new
  end

  def create
    if (user = User.authenticate_by(params.permit(:email_address, :password)))
      start_new_session_for user
      redirect_to after_authentication_url, notice: t(".signed_in_successfully")
    else
      redirect_to sign_in_url, alert: t(".invalid_credentials")
    end
  end

  def destroy
    terminate_session
    redirect_to sign_in_url, notice: t(".signed_out_successfully")
  end
end
