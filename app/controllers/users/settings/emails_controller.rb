# frozen_string_literal: true

class Users::Settings::EmailsController < ApplicationController
  before_action :set_user

  def update
    if @user.update(user_params)
      if @user.email_address_previously_changed?
        UsersMailer.email_verification(@user).deliver_later
        redirect_to users_settings_account_path, notice: t(".email_changed")
      else
        redirect_to users_settings_account_path
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.expect(user: [:email_address, :password_challenge])
  end

  def set_user
    @user = Current.user
  end
end
