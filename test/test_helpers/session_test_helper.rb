# frozen_string_literal: true

module SessionTestHelper
  def parsed_cookies
    ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
  end

  def sign_in_as(user_or_identity)
    cookies.delete :session_token

    identity = if user_or_identity.is_a?(User)
      user_or_identity.identity
    elsif user_or_identity.is_a?(Identity)
      user_or_identity
    else
      identities(user_or_identity)
    end

    Current.session = identity.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_token] = Current.session.signed_id
      cookies[:session_token] = cookie_jar[:session_token]
    end
  end

  def sign_out
    Current.session&.destroy!
    Current.reset
    cookies.delete(:session_token)
  end

  def with_current_user(user)
    user = users(user) unless user.is_a?(User)
    old_session = Current.session
    begin
      Current.session = Session.new(identity: user.identity)
      yield
    ensure
      Current.session = old_session
    end
  end
end
