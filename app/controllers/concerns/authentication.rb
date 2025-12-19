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
        return nil unless session

        # Restore account context first, then set session (which derives identity -> user)
        if (account_id = cookies.signed[:account_id])
          Current.account = Account.find_by(id: account_id)
        end

        # Check if identity has an active user in the current account
        if Current.account && session.identity.users.active.exists?(account: Current.account)
          session.resume(user_agent: request.user_agent, ip_address: request.remote_ip)
          session
        else
          # Clear cookies if session is invalid or user is deactivated
          cookies.delete(:session_id)
          cookies.delete(:account_id)
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

    def start_new_session_for(identity)
      # Determine which account to use - for now, use the first active user's account
      # TODO: If identity has multiple accounts, redirect to account selection
      user = identity.users.active.first
      return nil unless user

      Current.account = user.account
      identity.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
        cookies.signed.permanent[:account_id] = { value: user.account_id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
      cookies.delete(:account_id)
    end
end
