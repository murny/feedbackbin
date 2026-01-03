# frozen_string_literal: true

require "test_helper"

class MagicLinkMailerTest < ActionMailer::TestCase
  test "sign_in_instructions" do
    magic_link = magic_links(:valid)
    email = MagicLinkMailer.sign_in_instructions(magic_link)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ magic_link.identity.email_address ], email.to
    assert_includes email.subject, magic_link.code
  end

  test "sign_in_instructions includes code in body" do
    magic_link = magic_links(:valid)
    email = MagicLinkMailer.sign_in_instructions(magic_link)

    # Check both HTML and text parts
    html_part = email.html_part&.body&.to_s || ""
    text_part = email.text_part&.body&.to_s || ""
    combined_body = html_part + text_part

    assert_includes combined_body, magic_link.code
  end
end
