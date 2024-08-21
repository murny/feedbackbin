# frozen_string_literal: true

class Users::Settings::PasswordsController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to edit_users_settings_password_path, notice: t(".password_changed")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:password, :password_confirmation, :password_challenge).with_defaults(password_challenge: "")
  end

  def set_user
    @user = Current.user
  end
end
