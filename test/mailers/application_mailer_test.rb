# frozen_string_literal: true

require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  class TestMailer < ApplicationMailer
    def hello
      mail to: "recipient@example.com", subject: "hi", body: "body"
    end
  end

  test "from falls back to support address when MAILER_FROM_ADDRESS is unset" do
    ENV.delete("MAILER_FROM_ADDRESS")
    mail = TestMailer.hello

    assert_equal [ "support@feedbackbin.com" ], mail.from
  end

  test "from uses MAILER_FROM_ADDRESS env var when set" do
    ENV["MAILER_FROM_ADDRESS"] = "Custom <ops@example.com>"
    mail = TestMailer.hello

    assert_equal [ "ops@example.com" ], mail.from
  ensure
    ENV.delete("MAILER_FROM_ADDRESS")
  end
end
