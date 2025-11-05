# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/invitation_mailer
class InvitationsMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/invitation_mailer/invite
  def invite
    InvitationsMailer.with(invitation: Invitation.first).invite
  end
end
