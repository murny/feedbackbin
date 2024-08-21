# frozen_string_literal: true

class Users::Settings::ProfilesController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    if @user.update(user_params)
      redirect_to edit_users_settings_profile_path, notice: t(".profile_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.permit(:name, :bio)
  end

  def set_user
    @user = Current.user
  end
end
