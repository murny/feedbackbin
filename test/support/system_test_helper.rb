# frozen_string_literal: true

module SystemTestHelper
  # Sign in as a user in system tests
  # Uses the account-scoped session URL
  def sign_in_as(user, password: "secret123456")
    visit sign_in_url(script_name: nil)
    fill_in "Email", with: user.identity.email_address
    fill_in "Password", with: password
    click_button "Sign in"
  end

  # Default account for system tests
  def default_account
    @default_account ||= accounts(:feedbackbin)
  end

  # Generate account-scoped URL
  def account_url_for(path, account: default_account)
    "#{account.slug}#{path}"
  end
end
