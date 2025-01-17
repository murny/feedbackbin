# frozen_string_literal: true

module UserSettings
  class ConnectedAccountsController < ApplicationController
    skip_after_action :verify_authorized

    before_action :set_user_connected_account, only: [ :destroy ]

    def destroy
      @user_connected_account.destroy
      redirect_to user_settings_account_path, status: :see_other, notice: t(".disconnected_successfully")
    end

    private

    def set_user_connected_account
      @user_connected_account = Current.user.user_connected_accounts.find(params[:id])
    end
  end
end
