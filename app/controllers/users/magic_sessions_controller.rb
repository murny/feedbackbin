# frozen_string_literal: true

module Users
  # Magic link request controller.
  # Sends magic link email for passwordless authentication.
  class MagicSessionsController < ApplicationController
    include Authentication::ViaMagicLink

    disallow_account_scope
    require_unauthenticated_access

    skip_after_action :verify_authorized

    layout "auth"

    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { rate_limit_exceeded }

    def new
      store_return_to_url
    end

    def create
      store_return_to_url

      if (identity = Identity.find_by(email_address: email_address))
        redirect_to_session_magic_link identity.send_magic_link
      else
        redirect_to_fake_session_magic_link email_address
      end
    end

    private

      def email_address
        params.expect(:email_address)
      end

      def rate_limit_exceeded
        respond_to do |format|
          format.html { redirect_to magic_sign_in_path, alert: t(".rate_limited") }
          format.json { render json: { message: t(".rate_limited") }, status: :too_many_requests }
        end
      end
  end
end
