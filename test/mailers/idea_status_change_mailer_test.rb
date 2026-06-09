# frozen_string_literal: true

require "test_helper"

class IdeaStatusChangeMailerTest < ActionMailer::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    @event = events(:idea_status_changed)
    @recipient = users(:jane)
    @mail = IdeaStatusChangeMailer.with(event: @event, recipient: @recipient).status_changed
  end

  test "status_changed renders subject from i18n" do
    expected = I18n.t("idea_status_change_mailer.status_changed.subject", title: @event.eventable.title)

    assert_equal expected, @mail.subject
  end

  test "status_changed delivers to the recipient identity email address" do
    assert_equal [ @recipient.identity.email_address ], @mail.to
  end

  test "status_changed body includes the idea title" do
    assert_match @event.eventable.title, @mail.body.encoded
  end

  test "status_changed body includes the new status name" do
    assert_match @event.particulars["new_status"], @mail.body.encoded
  end

  test "status_changed body includes a link to the idea" do
    expected_path = Rails.application.routes.url_helpers.idea_path(@event.eventable, script_name: Current.account.slug)

    assert_match expected_path, @mail.body.encoded
  end
end
