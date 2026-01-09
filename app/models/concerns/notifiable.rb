# frozen_string_literal: true

# Notifiable concern enables automatic notification creation for models.
# Include this in models that should trigger notifications (e.g., Event).
#
# When included in Event, it will:
# 1. Create a has_many :notifications association
# 2. Automatically trigger notification creation after the record is created
# 3. Delegate to a Notifier class to determine recipients
#
# Example flow:
#   event = Event.create!(action: "idea_status_changed", ...)
#   -> after_create_commit triggers notify_recipients_later
#   -> NotifyRecipientsJob enqueued
#   -> Notifier.for(event).notify creates Notification records
module Notifiable
  extend ActiveSupport::Concern

  included do
    has_many :notifications, as: :source, dependent: :destroy
    after_create_commit :notify_recipients_later
  end

  # Synchronously create notifications for this event
  # Called by NotifyRecipientsJob
  def notify_recipients
    Notifier.for(self)&.notify
  end

  private

  # Asynchronously create notifications via background job
  def notify_recipients_later
    NotifyRecipientsJob.perform_later(self)
  end
end
