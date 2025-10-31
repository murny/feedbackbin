# frozen_string_literal: true

class InvitationMailer < ApplicationMailer
  def invite
    @invitation = params[:invitation]
    @invited_by = @invitation.invited_by

    mail(
      to: @invitation.email,
      subject: t(".subject")
    )
  end
end
