# frozen_string_literal: true

module UserSettings
  class ConnectedAccountsController < ApplicationController
    before_action :set_identity_connected_account, only: [ :destroy ]

    def destroy
      @identity_connected_account.destroy
      redirect_to user_settings_account_path, status: :see_other, notice: t(".disconnected_successfully")
    end

    private

      def set_identity_connected_account
        @identity_connected_account = Current.identity.identity_connected_accounts.find(params[:id])
      end
  end
end
