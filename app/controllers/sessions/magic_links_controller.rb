# frozen_string_literal: true

# Magic link verification controller.
# Authentication is global (untenanted). User provisioning for accounts
# happens via ensure_account_user when entering tenant scope.
class Sessions::MagicLinksController < ApplicationController
  include Authentication::ViaMagicLink

  disallow_account_scope
  require_unauthenticated_access

  skip_after_action :verify_authorized

  layout "auth"

  rate_limit to: 10, within: 15.minutes, only: :create, with: -> { rate_limit_exceeded }

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

    def ensure_that_email_address_pending_authentication_exists
      unless email_address_pending_authentication.present?
        respond_to do |format|
          format.html { redirect_to magic_sign_in_path, alert: t("sessions.magic_links.enter_email_address") }
          format.json { render json: { message: t("sessions.magic_links.enter_email_address") }, status: :unauthorized }
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
      magic_link.identity.update!(email_verified_at: Time.current) unless magic_link.identity.email_verified_at.present?
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
end
