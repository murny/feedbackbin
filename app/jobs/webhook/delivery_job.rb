# frozen_string_literal: true

# Webhook::DeliveryJob executes the actual HTTP request for a webhook delivery.
#
# This job:
# 1. Generates the JSON payload
# 2. Signs it with HMAC-SHA256
# 3. Sends HTTP POST request
# 4. Records response/errors
#
# Example:
#   Webhook::DeliveryJob.perform_later(delivery)
class Webhook::DeliveryJob < ApplicationJob
  queue_as :webhooks

  # Retry configuration for transient failures
  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  # Execute the webhook delivery
  # @param delivery [Webhook::Delivery] The delivery to execute
  def perform(delivery)
    delivery.deliver
  end
end
