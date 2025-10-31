# frozen_string_literal: true

require "test_helper"

class InvitationMailerTest < ActionMailer::TestCase
  test "invite" do
    invitation = invitations(:one)
    mail = InvitationMailer.with(invitation: invitation).invite

    assert_equal I18n.t("invitation_mailer.invite.subject"), mail.subject
    assert_equal [ invitation.email ], mail.to
    assert_match invitation.name, mail.body.encoded
    assert_match invitation.invited_by.name, mail.body.encoded
  end
end
