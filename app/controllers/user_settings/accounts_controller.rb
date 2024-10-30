# frozen_string_literal: true

module UserSettings
  class AccountsController < ApplicationController
    before_action :set_user

    def show
      @user_connected_accounts = Current.user.user_connected_accounts.order(provider_name: :asc, created_at: :desc)
    end

    def update
      if @user.update(user_params)
        redirect_to users_setting_account_path, notice: t(".account_updated")
      else
        render :show, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      redirect_to root_path, notice: t(".account_deleted")
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
