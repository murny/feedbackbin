# frozen_string_literal: true

module UserSettings
  class PreferencesController < ApplicationController
    before_action :set_user

    def show
    end

    def update
      if @user.update(user_params)
        redirect_to user_settings_preferences_path, notice: t(".updated_successfully")
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

      def user_params
        params.require(:user).permit(:preferred_language, :time_zone, :theme).compact
      end

      def set_user
        @user = Current.user
      end
  end
end
