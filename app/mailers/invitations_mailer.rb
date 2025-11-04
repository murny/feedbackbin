# frozen_string_literal: true

class InvitationsMailer < ApplicationMailer
  def invite
    @invitation = params[:invitation]
    @invited_by = @invitation.invited_by
    @organization = Current.organization

    mail(
      to: @invitation.email,
      subject: t(".subject", organization_name: @organization.name)
    )
  end
end
