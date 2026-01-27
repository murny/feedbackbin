# frozen_string_literal: true

module UserSettings
  class EmailsController < ApplicationController
    before_action :set_identity
    before_action :set_account_settings_data

    def update
      if @identity.has_password? && !@identity.authenticate(params.dig(:identity, :password_challenge))
        @identity.errors.add(:password_challenge, :invalid)
        return render "user_settings/accounts/show", status: :unprocessable_entity
      end

      new_email = email_change_params[:email_address].to_s.strip.downcase.presence

      if new_email.blank?
        @identity.errors.add(:email_address, :blank)
        return render "user_settings/accounts/show", status: :unprocessable_entity
      end

      if new_email == @identity.email_address
        redirect_to user_settings_account_path, notice: t(".email_has_not_changed")
      elsif Identity.exists?(email_address: new_email)
        @identity.errors.add(:email_address, :taken)
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

      def set_identity
        @identity = Current.identity
      end

      def set_account_settings_data
        @user = Current.user
        @identity_connected_accounts = Current.identity.identity_connected_accounts.order(provider_name: :asc, created_at: :desc)
      end
  end
end
