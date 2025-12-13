# frozen_string_literal: true

module UserSettings
  class EmailsController < ApplicationController
    skip_after_action :verify_authorized

    before_action :set_identity

    def update
      if @identity.update(identity_params)
        if @identity.email_address_previously_changed?
          @identity.users.update_all(email_verified: false)
          IdentityMailer.email_verification(@identity).deliver_later
          redirect_to user_settings_account_path, notice: t(".email_changed")
        else
          redirect_to user_settings_account_path, notice: t(".email_has_not_changed")
        end
      else
        @user = Current.user
        @user_connected_accounts = Current.identity.connected_accounts.order(provider_name: :asc, created_at: :desc)
        render "user_settings/accounts/show", status: :unprocessable_entity
      end
    end

    private

      def identity_params
        params.expect(identity: [ :email_address, :password_challenge ])
      end

      def set_identity
        @identity = Current.identity
      end
  end
end
