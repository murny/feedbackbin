# frozen_string_literal: true

module Users
  class EmailVerificationsController < ApplicationController
    disallow_account_scope
    allow_unauthenticated_access only: :show
    skip_after_action :verify_authorized

    before_action :set_identity, only: :show

    def show
      @identity.update!(email_verified: true)
      redirect_to root_url(script_name: @identity.users.first&.account&.slug), notice: t(".email_verified")
    end

    def create
      IdentityMailer.email_verification(Current.identity).deliver_later
      redirect_to root_url(script_name: Current.identity.users.first&.account&.slug), notice: t(".email_verification_sent")
    end

    private

      def set_identity
        @identity = Identity.find_by_token_for!(:email_verification, params[:token])
      rescue
        identity = Identity.find_by(email_address: params[:email_address])
        redirect_to root_url(script_name: identity&.users&.first&.account&.slug), alert: t("users.email_verifications.invalid_token")
      end
  end
end
