# frozen_string_literal: true

module Users
  class EmailVerificationsController < ApplicationController
    disallow_account_scope
    allow_unauthenticated_access only: :show
    skip_after_action :verify_authorized

    before_action :set_identity, only: :show

    def show
      @identity.update!(email_verified: true)
      redirect_to session_menu_path, notice: t(".email_verified")
    end

    def create
      IdentityMailer.email_verification(Current.identity).deliver_later
      redirect_to session_menu_path, notice: t(".email_verification_sent")
    end

    private

      def set_identity
        @identity = Identity.find_by_token_for!(:email_verification, params[:token])
      rescue
        redirect_to sign_in_path, alert: t("users.email_verifications.invalid_token")
      end
  end
end
