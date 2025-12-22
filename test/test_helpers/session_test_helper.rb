# frozen_string_literal: true

module SessionTestHelper
  def parsed_cookies
    ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
  end

  def sign_in_as(user)
    Current.session = user.identity.sessions.create!

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
end
