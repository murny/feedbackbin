# frozen_string_literal: true

module Users
  # Email verification controller.
  # Works in both tenant and non-tenant contexts.
  class EmailVerificationsController < ApplicationController
    include AuthLayout

    skip_before_action :require_account
    allow_unauthenticated_access only: %i[show pending]

    before_action :set_identity, only: :show

    def show
      @identity.update!(email_verified_at: Time.current) if @identity.email_verified_at.blank?
      start_new_session_for(@identity) unless authenticated?
      redirect_to after_verification_url, notice: t(".email_verified")
    end

    def pending
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

      def after_verification_url
        session_menu_path
      end
  end
end
