# frozen_string_literal: true

module UserSettings
  class PreferencesController < ApplicationController
    skip_after_action :verify_authorized

    before_action :set_user

    def show
    end

    def update
      if @user.update(user_params)
        respond_to do |format|
          format.html { redirect_to user_settings_preferences_path, notice: t(".updated_successfully") }
          format.turbo_stream { redirect_to user_settings_preferences_path, notice: t(".updated_successfully") }
        end
      else
        respond_to do |format|
          format.html { render :show, status: :unprocessable_entity }
          format.turbo_stream { render :show, status: :unprocessable_entity }
        end
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
