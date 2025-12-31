# frozen_string_literal: true

# Webhook::DispatchJob finds all webhooks that should be triggered by an event
# and creates delivery records for each one.
#
# This job is enqueued automatically when an Event is created.
#
# Flow:
#   Event created
#     -> Webhook::DispatchJob enqueued
#     -> Finds all active webhooks subscribed to event.action
#     -> Creates Webhook::Delivery for each
#     -> Each delivery automatically enqueues Webhook::DeliveryJob
#
# Example:
#   Webhook::DispatchJob.perform_later(event)
class Webhook::DispatchJob < ApplicationJob
  queue_as :webhooks

  # Find and trigger all webhooks for an event
  # @param event [Event] The event to dispatch webhooks for
  def perform(event)
    Webhook.active.triggered_by(event).find_each do |webhook|
      webhook.trigger(event)
    end
  end
end
