# frozen_string_literal: true

module UserSettings
  class EmailsController < ApplicationController
    skip_after_action :verify_authorized

    before_action :set_identity

    def update
      if @identity.authenticate(params.dig(:identity, :password_challenge)) && @identity.update(identity_params)
        if @identity.email_address_previously_changed?
          IdentityMailer.email_verification(@identity).deliver_later
          redirect_to user_settings_account_path, notice: t(".email_changed")
        else
          redirect_to user_settings_account_path, notice: t(".email_has_not_changed")
        end
      else
        @identity.errors.add(:password_challenge, :invalid) unless @identity.authenticate(params.dig(:identity, :password_challenge))
        @user = Current.user
        @identity_connected_accounts = Current.identity.identity_connected_accounts.order(provider_name: :asc, created_at: :desc)
        render "user_settings/accounts/show", status: :unprocessable_entity
      end
    end

    private

      def identity_params
        params.expect(identity: [ :email_address ])
      end

      def set_identity
        @identity = Current.identity
      end
  end
end
