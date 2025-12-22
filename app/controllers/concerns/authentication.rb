# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
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
  end

  private

    def authenticated?
      Current.session.present?
    end

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

    def redirect_authenticated_user
      redirect_to after_authentication_url if authenticated?
    end

    def find_session_by_cookie
      Session.find_signed(cookies[:session_token])
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to sign_in_path
    end

    def after_authentication_url
      url = session.delete(:return_to_after_authenticating)
      return url if url.present?

      # Redirect to user's first accessible account
      if Current.identity.present?
        user = Current.identity.users.active.first
        return root_url(script_name: user.account.slug) if user
      end

      root_path
    end

    def start_new_session_for(identity)
      identity.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        set_current_session session
      end
    end

    def set_current_session(session)
      Current.session = session
      cookies.permanent[:session_token] = { value: session.signed_id, httponly: true, same_site: :lax }
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_token)
    end
end
