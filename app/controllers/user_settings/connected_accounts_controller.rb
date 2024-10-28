# frozen_string_literal: true

module UserSettings
  class ConnectedAccountsController < ApplicationController
    before_action :set_user_connected_account, only: [:destroy]

    def index
      @user_connected_accounts = Current.user.user_connected_accounts.order(provider_name: :asc, created_at: :desc)
    end

    def destroy
      @user_connected_account.destroy
      redirect_to user_settings_connected_accounts_path, status: :see_other, notice: t(".disconnected_successfully")
    end

    private

    def set_user_connected_account
      @user_connected_account = Current.user.user_connected_accounts.find(params[:id])
    end
  end
end
