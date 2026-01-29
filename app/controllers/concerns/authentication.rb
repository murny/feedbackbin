# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_account
    before_action :require_authentication
    before_action :ensure_account_user

    helper_method :authenticated?
  end

  class_methods do
    # Allow both authenticated and unauthenticated access
    # For unauthenticated users: resume_session sets up session if cookie exists
    # For authenticated users: normal flow with user provisioning
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
      # Prepend resume_session so it runs BEFORE ensure_account_user
      # This ensures authenticated? returns true when ensure_account_user runs
      prepend_before_action :resume_session, **options
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

    # Store the return_to URL from params in the session.
    # Only stores URLs that belong to this application to prevent open redirects.
    def store_return_to_url
      return unless params[:return_to].present?

      uri = URI.parse(params[:return_to])

      # Only allow nil scheme (relative path) or http/https
      return unless uri.scheme.nil? || uri.scheme.downcase.in?(%w[http https])

      # Only allow nil host (relative path), exact host match, or subdomain of request host
      return unless uri.host.nil? || uri.host == request.host || uri.host.end_with?(".#{request.host}")

      session[:return_to_after_authenticating] = params[:return_to]
    rescue URI::InvalidURIError
      # Ignore invalid URLs
    end

    def ensure_account_user
      return unless Current.account.present? && authenticated?

      identity = Current.session.identity
      user = Current.account.users.find_by(identity: identity)

      if user.nil?
        Current.user = provision_user_for_account(identity)
      end
    end

    def provision_user_for_account(identity)
      identity.users.create!(
        account: Current.account,
        name: identity.email_address.split("@").first.titleize,
        role: :member
      )
    end
end
