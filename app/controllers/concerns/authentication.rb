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
      session&.resume(user_agent: request.user_agent, ip_address: request.remote_ip)
      session
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

  def start_new_session_for(user)
    user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
      Current.session = session
      cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
    end
  end

  def terminate_session
    Current.session.destroy
    cookies.delete(:session_id)
  end

  def clear_site_data
    # TODO: This is extremly slow, on local it takes at least 5 seconds to clear and is failing system tests.
    # Lets comment this out for now until we can find a better solution. Maybe cache and storage is too much?
    # More info: https://github.com/rails/rails/pull/54230
    # response.headers["Clear-Site-Data"] = '"cache","storage"'
  end
end
