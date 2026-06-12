# frozen_string_literal: true

class IdeaStatusChangeMailer < ApplicationMailer
  def status_changed
    @event = params.fetch(:event)
    @recipient = params.fetch(:recipient)
    @idea = @event.eventable
    @old_status = @event.particulars["old_status"]
    @new_status = @event.particulars["new_status"]

    mail(
      to: @recipient.identity.email_address,
      subject: t(".subject", title: @idea.title)
    )
  end
end
