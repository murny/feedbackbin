# frozen_string_literal: true

module UserSettings
  class ProfilesController < ApplicationController
    skip_after_action :verify_authorized

    before_action :set_user

    def show
    end

    def update
      if @user.update(user_params)
        redirect_to user_settings_profile_path, notice: update_notice
      else
        render :show, status: :unprocessable_entity
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
        t("user_settings.profiles.avatar_updated")
      else
        t("user_settings.profiles.profile_updated")
      end
    end
  end
end
