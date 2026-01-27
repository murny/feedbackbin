# frozen_string_literal: true

module Users
  class EmailChangeConfirmationsController < ApplicationController
    disallow_account_scope
    allow_unauthenticated_access

    before_action :set_identity

    def show
      if @identity.change_email_address_using_token(params[:token])
        terminate_session if Current.session
        start_new_session_for(@identity)
        redirect_to session_menu_path, notice: t(".email_changed_successfully")
      else
        redirect_to sign_in_path, alert: t(".email_change_failed")
      end
    end

    private

      def set_identity
        parsed_token = SignedGlobalID.parse(
          params[:token],
          for: Identity::EmailAddressChangeable::EMAIL_CHANGE_TOKEN_PURPOSE
        )
        @identity = parsed_token&.find
        redirect_to sign_in_path, alert: t("users.email_change_confirmations.invalid_or_expired_token") unless @identity
      end
  end
end
