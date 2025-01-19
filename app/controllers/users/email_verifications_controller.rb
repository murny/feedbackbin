# frozen_string_literal: true

module Users
  class EmailVerificationsController < ApplicationController
    allow_unauthenticated_access only: :show
    skip_after_action :verify_authorized

    before_action :set_user, only: :show

    def show
      @user.update!(email_verified: true)
      redirect_to root_path, notice: t(".email_verified")
    end

    def create
      UserMailer.email_verification(Current.user).deliver_later
      redirect_to root_path, notice: t(".email_verification_sent")
    end

    private

      def set_user
        @user = User.find_by_token_for!(:email_verification, params[:token])
      rescue
        redirect_to root_path, alert: t("users.email_verifications.invalid_token")
      end
  end
end
