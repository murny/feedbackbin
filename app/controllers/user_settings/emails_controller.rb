# frozen_string_literal: true

module UserSettings
  class EmailsController < ApplicationController
    skip_after_action :verify_authorized

    before_action :set_user

    def update
      if @user.update(user_params)
        if @user.email_address_previously_changed?
          UserMailer.email_verification(@user).deliver_later
          redirect_to user_settings_account_path, notice: t(".email_changed")
        else
          redirect_to user_settings_account_path, notice: t(".email_has_not_changed")
        end
      else
        @user_connected_accounts = Current.user.user_connected_accounts.order(provider_name: :asc, created_at: :desc)
        render "user_settings/accounts/show", status: :unprocessable_entity
      end
    end

    private

      def user_params
        params.expect(user: [ :email_address, :password_challenge ])
      end

    def set_user
      @user = Current.user
    end
  end
end
