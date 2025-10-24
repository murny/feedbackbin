# frozen_string_literal: true

module UserSettings
  class AccountsController < ApplicationController
    skip_after_action :verify_authorized

    before_action :set_user

    def show
      # TODO: Need to make this a hash with id and provider_name to simplify the view code and prevent repeated calls to the database
      @user_connected_accounts = Current.user.user_connected_accounts.order(provider_name: :asc, created_at: :desc)
    end

    def update
      if @user.update(user_params)
        redirect_to user_settings_account_path, notice: t(".account_updated")
      else
        render :show, status: :unprocessable_entity
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
