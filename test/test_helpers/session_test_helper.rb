# frozen_string_literal: true

module SessionTestHelper
  def parsed_cookies
    ActionDispatch::Cookies::CookieJar.build(request, cookies.to_hash)
  end

  def sign_in_as(user)
    Current.session = user.identity.sessions.create!
    cookies[:session_token] = Current.session.signed_id
  end

  def sign_out
    Current.session&.destroy!
    Current.reset
    cookies.delete(:session_token)
  end
end
