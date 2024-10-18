# frozen_string_literal: true

module Users
  module Settings
    class ConnectedAccountsController < ApplicationController
      before_action :set_connected_account, only: [:destroy]

      def index
        @connected_accounts = Current.user.user_identities.order(provider_name: :asc, created_at: :desc)
      end

      def destroy
        @connected_account.destroy
        redirect_to users_settings_connected_accounts_path, status: :see_other
      end

      private

      def set_connected_account
        @connected_account = Current.user.user_identities.find(params[:id])
      end
    end
  end
end
