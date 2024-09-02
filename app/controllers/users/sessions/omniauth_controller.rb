# frozen_string_literal: true

class Users::Sessions::OmniauthController < ApplicationController
  skip_before_action :verify_authenticity_token
  skip_before_action :authenticate_user!

  def create
    @user = User.create_with(user_params).find_or_initialize_by(omniauth_params)

    if @user.save
      start_new_session_for(@user)

      redirect_to root_path, notice: t("signed_in_successfully")
    else
      redirect_to new_user_session_path, alert: t(".authentication_failed")
    end
  end

  def failure
    redirect_to new_user_session_path, alert: params[:message]
  end

  private

  def user_params
    {email: omniauth.info.email, password: SecureRandom.base58, email_verified: true}
  end

  def omniauth_params
    {provider: omniauth.provider, uid: omniauth.uid}
  end

  def omniauth
    request.env["omniauth.auth"]
  end
end
