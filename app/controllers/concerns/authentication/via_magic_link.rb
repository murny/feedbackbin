# frozen_string_literal: true

module Authentication::ViaMagicLink
  extend ActiveSupport::Concern

  included do
    after_action :ensure_development_magic_link_not_leaked
  end

  private

    def ensure_development_magic_link_not_leaked
      unless Rails.env.development?
        raise "Leaking magic link via flash in #{Rails.env}?" if flash[:magic_link_code].present?
      end
    end

    def redirect_to_fake_session_magic_link(email_address, **options)
      fake_magic_link = MagicLink.new(
        identity: Identity.new(email_address: email_address),
        code: SecureRandom.base32(6),
        expires_at: MagicLink::EXPIRATION_TIME.from_now
      )

      redirect_to_session_magic_link fake_magic_link, **options
    end

    def redirect_to_session_magic_link(magic_link, return_to: nil)
      serve_development_magic_link(magic_link)
      set_pending_authentication_token(magic_link)
      store_authentication_context(return_to: return_to)

      respond_to do |format|
        format.html { redirect_to session_magic_link_path }
        format.json { render json: { pending_authentication_token: pending_authentication_token }, status: :created }
      end
    end

    def serve_development_magic_link(magic_link)
      if Rails.env.development? && magic_link.present?
        flash[:magic_link_code] = magic_link.code
        response.set_header("X-Magic-Link-Code", magic_link.code)
      end
    end

    def set_pending_authentication_token(magic_link)
      cookies[:pending_authentication_token] = {
        value: pending_authentication_token_verifier.generate(magic_link.identity.email_address, expires_at: magic_link.expires_at),
        httponly: true,
        same_site: :lax,
        expires: magic_link.expires_at
      }
    end

    # Store authentication context (account and return URL) for restoration after magic link verification
    def store_authentication_context(return_to: nil)
      session[:return_to_after_authenticating] = return_to if return_to
      session[:authentication_account_id] = Current.account&.external_account_id
    end

    # Restore account context stored during magic link request
    def restore_authentication_context
      if (external_account_id = session.delete(:authentication_account_id))
        Account.find_by(external_account_id: external_account_id)
      end
    end

    def email_address_pending_authentication
      pending_authentication_token_verifier.verified(pending_authentication_token)
    end

    def pending_authentication_token_verifier
      Rails.application.message_verifier(:pending_authentication)
    end

    def pending_authentication_token
      cookies[:pending_authentication_token]
    end

    def clear_pending_authentication_token
      cookies.delete(:pending_authentication_token)
    end
end
