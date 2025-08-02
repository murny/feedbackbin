# frozen_string_literal: true

module SystemTestHelper
  include ActionView::Helpers::JavaScriptHelper

  def sign_in(email_address, password = "secret123456")
    visit sign_in_url

    fill_in "Email", with: email_address
    fill_in "Password", with: password

    click_button "Sign in"

    assert_selector "a", text: "New Post"
  end
end
