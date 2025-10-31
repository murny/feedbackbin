# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/invitation_mailer
class InvitationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/invitation_mailer/invite
  def invite
    InvitationMailer.with(invitation: Invitation.first).invite
  end
end
