# frozen_string_literal: true

# Unified session controller for Identity authentication.
# Works in both tenanted and untenanted contexts:
# - Untenanted: Signs in Identity, redirects to session menu
# - Tenanted: Signs in Identity, creates User for account if needed, redirects to account root
class SessionsController < ApplicationController
  skip_before_action :require_account
  allow_unauthenticated_access only: %i[new create]
  before_action :redirect_authenticated_user, only: %i[new create]
  skip_after_action :verify_authorized

  layout :determine_layout

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_in_path, alert: t("sessions.create.rate_limited") }

  def new
  end

  def create
    if (identity = Identity.authenticate_by(params.permit(:email_address, :password)))
      handle_successful_authentication(identity)
    else
      redirect_to sign_in_path, alert: t(".invalid_credentials")
    end
  end

  def destroy
    terminate_session
    redirect_to sign_in_url(script_name: ""), notice: t(".signed_out_successfully")
  end

  private

    def handle_successful_authentication(identity)
      if Current.account.present?
        handle_tenanted_authentication(identity)
      else
        handle_untenanted_authentication(identity)
      end
    end

    def handle_tenanted_authentication(identity)
      user = Current.account.users.find_by(identity: identity)

      if user.nil?
        # Identity exists but no user for this account - create one
        create_user_for_account(identity)
      elsif !user.active?
        redirect_to sign_in_path, alert: t("sessions.create.account_deactivated")
        return
      end

      start_new_session_for(identity)
      redirect_to after_authentication_url, notice: t("sessions.create.signed_in_successfully")
    end

    def handle_untenanted_authentication(identity)
      if identity.users.active.none?
        redirect_to sign_in_path, alert: t("sessions.create.account_deactivated")
      else
        start_new_session_for(identity)
        redirect_to after_authentication_url, notice: t("sessions.create.signed_in_successfully")
      end
    end

    def create_user_for_account(identity)
      identity.users.create!(
        account: Current.account,
        name: identity.email_address.split("@").first.titleize,
        role: :member
      )
    end

    def redirect_authenticated_user
      redirect_to after_authentication_url if authenticated?
    end

    def determine_layout
      Current.account.present? ? "application" : "auth"
    end
end
