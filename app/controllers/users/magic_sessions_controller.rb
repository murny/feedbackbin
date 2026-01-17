# frozen_string_literal: true

module Users
  # Magic link request controller - works in both tenanted and untenanted contexts.
  # Sends magic link email for passwordless authentication.
  class MagicSessionsController < ApplicationController
    include Authentication::ViaMagicLink

    skip_before_action :require_account
    require_unauthenticated_access
    skip_after_action :verify_authorized

    layout :determine_layout

    rate_limit to: 10, within: 3.minutes, only: :create, with: -> { rate_limit_exceeded }

    def new
    end

    def create
      if (identity = Identity.find_by(email_address: email_address))
        sign_in identity
      else
        redirect_to_fake_session_magic_link email_address
      end
    end

    private

      def email_address
        params.expect(:email_address)
      end

      def sign_in(identity)
        redirect_to_session_magic_link identity.send_magic_link
      end

      def rate_limit_exceeded
        respond_to do |format|
          format.html { redirect_to magic_sign_in_path, alert: t(".rate_limited") }
          format.json { render json: { message: t(".rate_limited") }, status: :too_many_requests }
        end
      end

      def determine_layout
        Current.account.present? ? "application" : "auth"
      end
  end
end
