# frozen_string_literal: true

module UserSettings
  class EmailsController < ApplicationController
    skip_after_action :verify_authorized

    before_action :set_identity
    before_action :validate_password_challenge, only: :update, if: -> { @identity.has_password? }

    def update
      new_email = email_change_params[:email_address]

      if new_email == @identity.email_address
        redirect_to user_settings_account_path, notice: t(".email_has_not_changed")
      elsif Identity.exists?(email_address: new_email)
        @identity.errors.add(:email_address, :taken)
        @user = Current.user
        @identity_connected_accounts = Current.identity.identity_connected_accounts.order(provider_name: :asc, created_at: :desc)
        render "user_settings/accounts/show", status: :unprocessable_entity
      else
        @identity.send_email_address_change_confirmation(new_email)
        redirect_to user_settings_account_path, notice: t(".verification_email_sent")
      end
    end

    private

      def email_change_params
        params.expect(identity: [ :email_address ])
      end

      def validate_password_challenge
        password_challenge = params.dig(:identity, :password_challenge)
        unless @identity.authenticate(password_challenge)
          @identity.errors.add(:password_challenge, :invalid)
          @user = Current.user
          @identity_connected_accounts = Current.identity.identity_connected_accounts.order(provider_name: :asc, created_at: :desc)
          render "user_settings/accounts/show", status: :unprocessable_entity
        end
      end

      def set_identity
        @identity = Current.identity
      end
  end
end
