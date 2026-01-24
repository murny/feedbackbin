# frozen_string_literal: true

module Sessions
  # Magic link request controller.
  # Sends magic link email for passwordless authentication.
  # Works in both tenant and non-tenant contexts.
  class MagicLinkRequestsController < ApplicationController
    include Authentication::ViaMagicLink
    include AuthLayout

    skip_before_action :require_account
    require_unauthenticated_access

    skip_after_action :verify_authorized

    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { rate_limit_exceeded }

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
          format.html { redirect_to sign_in_path, alert: t(".rate_limited") }
          format.json { render json: { message: t(".rate_limited") }, status: :too_many_requests }
        end
      end
  end
end
