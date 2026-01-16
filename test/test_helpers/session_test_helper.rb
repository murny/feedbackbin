# frozen_string_literal: true

module SessionTestHelper
  def parsed_cookies
    ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
  end

  def sign_in_as(identity)
    cookies.delete :session_token

    if identity.is_a?(User)
      user = identity
      identity = user.identity
      raise "User is not associated with an identity" unless identity
    elsif !identity.is_a?(Identity)
      identity = identities(identity)
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

  def with_multi_tenant_mode(enabled)
    previous = Account.multi_tenant
    Account.multi_tenant = enabled
    yield
  ensure
    Account.multi_tenant = previous
  end
end
