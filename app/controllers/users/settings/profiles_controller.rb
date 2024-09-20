# frozen_string_literal: true

class Users::Settings::ProfilesController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to edit_users_settings_profile_path, notice: update_notice
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :avatar, :email_address, :password, :bio).compact
  end

  def set_user
    @user = Current.user
  end

  def update_notice
    if params[:user][:avatar]
      "It may take up to 30 minutes to change your avatar everywhere."
    else
      t(".profile_updated")
    end
  end
end
