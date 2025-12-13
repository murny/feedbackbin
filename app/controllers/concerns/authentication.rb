# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= begin
        session = find_session_by_cookie
        if session&.identity
          # Check if identity has an active user for the current account
          if session.current_account && session.user&.active?
            session.resume(user_agent: request.user_agent, ip_address: request.remote_ip)
            session
          elsif session.current_account.nil? && session.identity.accounts.any?
            # Auto-select first account if none set
            first_active_user = session.identity.users.active.first
            if first_active_user
              session.update!(current_account: first_active_user.account)
              session.resume(user_agent: request.user_agent, ip_address: request.remote_ip)
              session
            else
              cookies.delete(:session_id)
              nil
            end
          elsif session.current_account.nil? && session.identity.accounts.none?
            # Identity is authenticated but has no account memberships yet (e.g. just signed up).
            session.resume(user_agent: request.user_agent, ip_address: request.remote_ip)
            session
          else
            cookies.delete(:session_id)
            nil
          end
        else
          cookies.delete(:session_id) if session
          nil
        end
      end
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to sign_in_path
    end

    def after_authentication_url
      session.delete(:return_to_after_authenticating) || root_path
    end

    def start_new_session_for(identity, account: nil)
      # Default to first active user's account if not specified
      account ||= identity.users.active.first&.account

      identity.sessions.create!(
        user_agent: request.user_agent,
        ip_address: request.remote_ip,
        current_account: account
      ).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
