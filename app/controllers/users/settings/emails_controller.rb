# frozen_string_literal: true

class Users::Settings::EmailsController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    if @user.update(user_params)
      if @user.email_address_previously_changed?
        UsersMailer.email_verification(@user).deliver_later
        redirect_to root_path, notice: t(".email_changed")
      else
        redirect_to root_path
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:email_address, :password_challenge).with_defaults(password_challenge: "")
  end

  def set_user
    @user = Current.user
  end
end
