# frozen_string_literal: true

module Users
  class PasswordResetsController < ApplicationController
    allow_unauthenticated_access
    skip_after_action :verify_authorized

    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_users_password_reset_path, alert: t("users.password_resets.create.rate_limited") }

    before_action :set_user_by_token, only: %i[edit update]

    def new
    end

    def edit
    end

    def create
      if (user = User.find_by(email_address: params[:email_address], email_verified: true))
        UserMailer.password_reset(user).deliver_later
      end

      redirect_to sign_in_path, notice: t(".password_reset_instructions_sent")
    end

    def update
      if @user.update(params.permit(:password, :password_confirmation))
        redirect_to sign_in_path, notice: t(".password_has_been_reset")
      else
        redirect_to edit_users_password_reset_path(params[:token]), alert: t(".passwords_did_not_match")
      end
    end

    private

      def set_user_by_token
        @user = User.find_by_password_reset_token!(params[:token])
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        redirect_to new_users_password_reset_path, alert: t("users.password_resets.password_reset_link_is_invalid")
      end
  end
end
