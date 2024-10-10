# frozen_string_literal: true

class Users::Settings::AccountsController < ApplicationController
  before_action :set_user

  def show
  end

  def update
    if @user.update(user_params)
      redirect_to users_settings_account_path, notice: t(".account_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:username).compact
  end

  def set_user
    @user = Current.user
  end
end
