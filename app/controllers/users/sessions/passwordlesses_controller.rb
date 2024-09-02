# frozen_string_literal: true

class Users::Sessions::PasswordlessesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:new]

  before_action :require_lock, only: :create
  before_action :set_user, only: :edit

  def new
  end

  def edit
    sign_in(@user)

    revoke_tokens
    redirect_to(root_path, notice: t("signed_in_successfully"))
  end

  def create
    if (@user = User.find_by(email: params[:email], email_verified: true))
      send_passwordless_email

      redirect_to new_user_session_path, notice: t(".check_email_for_sign_in_instructions")
    else
      redirect_to new_user_sessions_passwordless_path, alert: t(".verify_email_first")
    end
  end

  private

  def set_user
    token = SignInToken.find_signed!(params[:sid])
    @user = token.user
  rescue
    redirect_to new_user_sessions_passwordless_path, alert: t(".invalid_sign_in_link")
  end

  def send_passwordless_email
    UserMailer.with(user: @user).passwordless.deliver_later
  end

  def revoke_tokens
    @user.sign_in_tokens.delete_all
  end
end
