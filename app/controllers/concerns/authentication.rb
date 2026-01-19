# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_account
    before_action :require_authentication

    helper_method :authenticated?
  end

  class_methods do
    # Allow both authenticated and unauthenticated access
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      before_action :resume_session, **options
    end

    # Only allow unauthenticated access - redirect authenticated users away
    def require_unauthenticated_access(**options)
      allow_unauthenticated_access(**options)
      before_action :redirect_authenticated_user, **options
    end

    # Skip account requirement for controllers/actions that work without account scope
    # Used for auth pages (sign_in, signup, etc.) that should work globally
    def disallow_account_scope(**options)
      skip_before_action :require_account, **options
      before_action :redirect_if_account_scope, **options
    end
  end

  private

    def authenticated?
      Current.session.present?
    end

    # Account scoping

    def require_account
      unless Current.account.present?
        redirect_to session_menu_path(script_name: nil)
      end
    end

    def redirect_if_account_scope
      return unless Current.account.present?

      redirect_to url_for(script_name: nil), allow_other_host: true
    end

    # Authentication

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= begin
        session = find_session_by_cookie
        return nil unless session

        session.resume(user_agent: request.user_agent, ip_address: request.remote_ip)
        session
      end
    end

    def find_session_by_cookie
      Session.find_signed(cookies.signed[:session_token])
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to sign_in_path
    end

    def redirect_authenticated_user
      redirect_to after_authentication_url if authenticated?
    end

    # Session management

    def start_new_session_for(identity)
      identity.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        set_current_session session
      end
    end

    def set_current_session(session)
      Current.session = session
      cookies.signed.permanent[:session_token] = { value: session.signed_id, httponly: true, same_site: :lax }
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_token)
    end

    # Returns the URL to redirect to after authentication.
    # If there's a stored return URL, uses that.
    # If in tenant context, returns tenant root.
    # Otherwise, returns the session menu.
    def after_authentication_url
      session.delete(:return_to_after_authenticating) || default_after_authentication_url
    end

    def default_after_authentication_url
      if Current.account.present?
        root_path
      else
        session_menu_path(script_name: nil)
      end
    end
end
