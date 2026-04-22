# frozen_string_literal: true

require "test_helper"

class ApplicationMailerTest < ActionMailer::TestCase
  test "default from falls back to FeedbackBin support address when MAILER_FROM_ADDRESS is unset" do
    assert_equal "FeedbackBin <support@feedbackbin.com>", ApplicationMailer.default[:from]
  end

  test "default from is resolved at class load time (deploy-level config, not runtime)" do
    skip "ENV.fetch in `default from:` is evaluated once at class load. Integration check happens at deploy time via MAILER_FROM_ADDRESS env var."
  end
end
