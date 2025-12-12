# frozen_string_literal: true

require "test_helper"

class InvitationsMailerTest < ActionMailer::TestCase
  test "invite" do
    invitation = invitations(:one)
    account = Current.account
    mail = InvitationsMailer.with(invitation: invitation).invite

    assert_equal I18n.t("invitations_mailer.invite.subject", account_name: account.name), mail.subject
    assert_equal [ invitation.email ], mail.to
    assert_match invitation.name, mail.body.encoded
    assert_match invitation.invited_by.name, mail.body.encoded
    assert_match account.name, mail.body.encoded
    assert_match invitation.token, mail.body.encoded
  end
end
