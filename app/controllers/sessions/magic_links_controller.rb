# frozen_string_literal: true

# Magic link verification controller - works in both tenanted and untenanted contexts.
# Verifies magic link code and signs in the user.
# Restores account context from session if magic link was requested from a tenant.
class Sessions::MagicLinksController < ApplicationController
  include Authentication::ViaMagicLink

  skip_before_action :require_account
  require_unauthenticated_access
  skip_after_action :verify_authorized

  layout :determine_layout

  rate_limit to: 10, within: 15.minutes, only: :create, with: -> { rate_limit_exceeded }

  before_action :restore_account_context_from_session
  before_action :ensure_that_email_address_pending_authentication_exists

  helper_method :email_address_pending_authentication

  def show
  end

  def create
    if (magic_link = MagicLink.consume(code))
      authenticate magic_link
    else
      invalid_code
    end
  end

  private

    # Restore account context stored when magic link was requested.
    # This preserves tenant context through the verification flow.
    def restore_account_context_from_session
      return if Current.account.present? # Already in tenant context via URL

      if (account = restore_authentication_context)
        Current.account = account
      end
    end

    def ensure_that_email_address_pending_authentication_exists
      unless email_address_pending_authentication.present?
        respond_to do |format|
          format.html { redirect_to magic_sign_in_path, alert: t("sessions.magic_links.ensure_that_email_address_pending_authentication_exists.enter_email_address") }
          format.json { render json: { message: t("sessions.magic_links.ensure_that_email_address_pending_authentication_exists.enter_email_address") }, status: :unauthorized }
        end
      end
    end

    def code
      params.expect(:code)
    end

    def authenticate(magic_link)
      if ActiveSupport::SecurityUtils.secure_compare(email_address_pending_authentication || "", magic_link.identity.email_address)
        sign_in magic_link
      else
        email_address_mismatch
      end
    end

    def sign_in(magic_link)
      clear_pending_authentication_token

      if Current.account.present?
        handle_tenanted_sign_in(magic_link)
      else
        handle_untenanted_sign_in(magic_link)
      end
    end

    def handle_tenanted_sign_in(magic_link)
      identity = magic_link.identity

      # Create user for account if needed
      unless Current.account.users.exists?(identity: identity)
        identity.users.create!(
          account: Current.account,
          name: identity.email_address.split("@").first.titleize,
          role: :member
        )
      end

      start_new_session_for(identity)

      respond_to do |format|
        format.html { redirect_to root_url(script_name: Current.account.slug), notice: t("sessions.magic_links.sign_in.signed_in_successfully") }
        format.json { render json: { session_token: cookies.signed[:session_token] } }
      end
    end

    def handle_untenanted_sign_in(magic_link)
      start_new_session_for(magic_link.identity)

      respond_to do |format|
        format.html { redirect_to after_sign_in_url(magic_link), notice: t("sessions.magic_links.sign_in.signed_in_successfully") }
        format.json { render json: { session_token: cookies.signed[:session_token] } }
      end
    end

    def email_address_mismatch
      clear_pending_authentication_token

      respond_to do |format|
        format.html { redirect_to magic_sign_in_path, alert: t("sessions.magic_links.email_address_mismatch.something_went_wrong") }
        format.json { render json: { message: t("sessions.magic_links.email_address_mismatch.something_went_wrong") }, status: :unauthorized }
      end
    end

    def invalid_code
      respond_to do |format|
        format.html { redirect_to session_magic_link_path, flash: { shake: true, alert: t("sessions.magic_links.invalid_code.try_another_code") } }
        format.json { render json: { message: t("sessions.magic_links.invalid_code.try_another_code") }, status: :unauthorized }
      end
    end

    def after_sign_in_url(magic_link)
      if magic_link.for_sign_up?
        signup_path
      else
        after_authentication_url
      end
    end

    def rate_limit_exceeded
      respond_to do |format|
        format.html { redirect_to session_magic_link_path, alert: t("sessions.magic_links.rate_limit_exceeded.rate_limited") }
        format.json { render json: { message: t("sessions.magic_links.rate_limit_exceeded.rate_limited") }, status: :too_many_requests }
      end
    end

    def determine_layout
      Current.account.present? ? "application" : "auth"
    end
end
