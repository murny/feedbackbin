# frozen_string_literal: true

class Users::Settings::ProfilesController < ApplicationController
  before_action :set_user

  def show
  end

  def update
    if @user.update(user_params)
      redirect_to users_settings_profile_path, notice: update_notice
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :avatar, :bio).compact
  end

  def set_user
    @user = Current.user
  end

  def update_notice
    if params[:user][:avatar]
      t("users.settings.profiles.avatar_updated")
    else
      t("users.settings.profiles.profile_updated")
    end
  end
end
