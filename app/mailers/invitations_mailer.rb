# frozen_string_literal: true

class InvitationsMailer < ApplicationMailer
  def invite
    @invitation = params.fetch(:invitation)
    @invited_by = @invitation.invited_by
    @account = Current.account

    mail(
      to: @invitation.email,
      subject: t(".subject", account_name: @account.name)
    )
  end
end
