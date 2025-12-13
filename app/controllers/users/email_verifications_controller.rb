# frozen_string_literal: true

module Users
  class EmailVerificationsController < ApplicationController
    allow_unauthenticated_access only: :show
    skip_after_action :verify_authorized

    before_action :set_identity, only: :show

    def show
      @identity.users.update_all(email_verified: true)
      redirect_to root_path, notice: t(".email_verified")
    end

    def create
      IdentityMailer.email_verification(Current.identity).deliver_later
      redirect_to root_path, notice: t(".email_verification_sent")
    end

    private

      def set_identity
        @identity = Identity.find_by_email_verification_token!(params[:token])
      rescue ActiveSupport::MessageVerifier::InvalidSignature
        redirect_to root_path, alert: t("users.email_verifications.invalid_token")
      end
  end
end
