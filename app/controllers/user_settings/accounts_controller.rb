# frozen_string_literal: true

module UserSettings
  class AccountsController < ApplicationController
    before_action :set_user

    def show
    end

    def update
      if @user.update(user_params)
        redirect_to users_setting_account_path, notice: t(".account_updated")
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
end
