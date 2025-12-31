# frozen_string_literal: true

# Webhook::Triggerable provides filtering and delivery creation for webhooks.
#
# Included in Webhook model to add:
# - Scopes for filtering webhooks by event
# - Method to trigger delivery for an event
module Webhook::Triggerable
  extend ActiveSupport::Concern

  included do
    # Find webhooks that should be triggered by an event
    scope :triggered_by, ->(event) {
      where(account: event.account)
        .where("board_id IS NULL OR board_id = ?", event.board_id)
        .triggered_by_action(event.action)
    }

    # Find webhooks subscribed to a specific action
    scope :triggered_by_action, ->(action) {
      where("JSON_CONTAINS(subscribed_actions, ?)", "\"#{action}\"")
    }
  end

  # Create a delivery for this webhook and event
  # @param event [Event] The event that triggered the webhook
  # @return [Webhook::Delivery] The created delivery
  def trigger(event)
    deliveries.create!(event: event)
  end
end
