# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
    helper_method :current_user
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private

  def authenticated?
    current_user.present?
  end

  def current_user
    Current.user ||= begin
      resume_session
      Current.user
    end
  end

  def require_authentication
    resume_session || request_authentication
  end

  def resume_session
    if (session = find_session_by_cookie)
      set_current_session session
    end
  end

  def find_session_by_cookie
    if (token = cookies.encrypted[:session_token])
      Session.find_by(id: token)
    end
  end

  def request_authentication
    session[:return_to_after_authenticating] = request.url
    redirect_to sign_in_url
  end

  def after_authentication_url
    session.delete(:return_to_after_authenticating) || root_url
  end

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      set_current_session session
    end
  end

  def set_current_session(session)
    Current.session = session
    Current.user = session.user
    cookies.encrypted.permanent[:session_token] = {value: session.id, httponly: true, same_site: :lax}
  end

  def terminate_session
    Current.session.destroy
    cookies.delete(:session_token)
  end
end
