# frozen_string_literal: true

class PasswordsController < ApplicationController
  allow_unauthenticated_access
  before_action :set_user_by_token, only: %i[edit update]

  def new
  end

  def edit
  end

  def create
    if (user = User.find_by(email_address: params[:email_address]))
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to sign_in_url, notice: t(".password_reset_instructions_sent")
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      redirect_to sign_in_url, notice: t(".password_has_been_reset")
    else
      redirect_to edit_password_url(params[:token]), alert: t(".passwords_did_not_match")
    end
  end

  private

  def set_user_by_token
    @user = User.find_by!(password_reset_token: params[:token])
  rescue ActiveSupport::MessageVerifier::InvalidSignature
    redirect_to new_password_url, alert: t("passwords.password_reset_link_is_invalid")
  end
end
