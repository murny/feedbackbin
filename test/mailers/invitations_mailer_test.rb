# frozen_string_literal: true

require "test_helper"

class InvitationsMailerTest < ActionMailer::TestCase
  test "invite" do
    invitation = invitations(:one)
    organization = Current.organization
    mail = InvitationsMailer.with(invitation: invitation).invite

    assert_equal I18n.t("invitations_mailer.invite.subject", organization_name: organization.name), mail.subject
    assert_equal [ invitation.email ], mail.to
    assert_match invitation.name, mail.body.encoded
    assert_match invitation.invited_by.name, mail.body.encoded
    assert_match organization.name, mail.body.encoded
  end
end
