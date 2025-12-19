# frozen_string_literal: true

module SessionTestHelper
  def parsed_cookies
    ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
  end

  def sign_in_as(user)
    # Set account first (like the real auth flow), then session derives identity -> user
    Current.account = user.account
    Current.session = user.identity.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = Current.session.id
      cookie_jar.signed[:account_id] = user.account_id
      cookies[:session_id] = cookie_jar[:session_id]
      cookies[:account_id] = cookie_jar[:account_id]
    end
  end

  def sign_out
    Current.session&.destroy!
    Current.reset
    cookies.delete(:session_id)
    cookies.delete(:account_id)
  end
end
