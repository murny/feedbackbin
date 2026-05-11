# frozen_string_literal: true

module SystemTestHelper
  # Sign in as a user in system tests
  # Uses the account-scoped session URL
  def sign_in_as(user, password: "secret123456")
    visit sign_in_url(script_name: nil)
    fill_in "Email", with: user.identity.email_address
    click_link "Or sign in with password"
    fill_in "Password", with: password
    click_button "Sign in"

    assert_text "You have signed in successfully."
  end

  # Default account for system tests
  def default_account
    @default_account ||= accounts(:feedbackbin)
  end

  # Generate account-scoped URL
  def account_url_for(path, account: default_account)
    "#{account.slug}#{path}"
  end

  # Fill in a Lexxy rich-text editor (FeedbackBin uses Lexxy, not Trix, so the
  # built-in fill_in_rich_text_area helper does not work).
  def fill_in_lexxy(selector = "lexxy-editor", with:)
    editor_element = find(selector)
    editor_element.set with
    page.execute_script("arguments[0].value = arguments[1]", editor_element, with)
  end
end
