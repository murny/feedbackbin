# frozen_string_literal: true

# NotifyRecipientsJob creates notifications for event recipients.
# This job is enqueued automatically when an Event is created.
#
# The job:
# 1. Finds the appropriate Notifier for the event
# 2. Calls notify() to create Notification records
# 3. Each notification triggers a broadcast to update the UI
#
# Example:
#   NotifyRecipientsJob.perform_later(event)
class NotifyRecipientsJob < ApplicationJob
  queue_as :default

  # Create notifications for an event
  # @param notifiable [Event] The event that should trigger notifications
  def perform(notifiable)
    notifiable.notify_recipients
  end
end
