# frozen_string_literal: true

require "net/http"
require "openssl"

# Webhook::Delivery represents a single webhook delivery attempt.
# It handles:
# - Payload generation and signing (HMAC-SHA256)
# - HTTP request execution
# - Response tracking
# - Error handling
#
# State machine:
#   pending -> in_progress -> completed (or errored)
class Webhook::Delivery < ApplicationRecord
  self.table_name = "webhook_deliveries"

  belongs_to :webhook
  belongs_to :event

  # State machine for delivery status
  enum :state, {
    pending: "pending",
    in_progress: "in_progress",
    completed: "completed",
    errored: "errored"
  }, prefix: true

  # Automatically deliver webhook after creation
  after_create_commit :deliver_later

  # Deliver the webhook synchronously
  def deliver
    state_in_progress!

    # Build the request
    uri = URI.parse(webhook.url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == "https")
    http.open_timeout = 5
    http.read_timeout = 7
    http.write_timeout = 5

    # Create request
    request = Net::HTTP::Post.new(uri.request_uri)
    request["Content-Type"] = "application/json"
    request["User-Agent"] = "FeedbackBin-Webhook/1.0"
    request["X-Webhook-Signature"] = signature
    request["X-Webhook-Timestamp"] = event.created_at.utc.iso8601
    request.body = payload

    # Store request data
    self.request = {
      headers: {
        "Content-Type" => "application/json",
        "User-Agent" => "FeedbackBin-Webhook/1.0",
        "X-Webhook-Signature" => signature,
        "X-Webhook-Timestamp" => event.created_at.utc.iso8601
      },
      body: payload,
      url: webhook.url
    }

    # Execute request
    response = http.request(request)

    # Store response data
    self.response = {
      code: response.code.to_i,
      body: response.body&.slice(0, 1000), # Limit to 1KB
      headers: response.to_hash.slice("content-type", "content-length")
    }

    state_completed!
    save!
  rescue => error
    # Store error details
    self.response = {
      error: error.class.name,
      message: error.message
    }

    state_errored!
    save!
    raise
  end

  # Check if delivery succeeded
  def succeeded?
    completed? && response.present? && response["code"]&.between?(200, 299)
  end

  # Check if delivery failed
  def failed?
    errored? || (completed? && !succeeded?)
  end

  private

  # Generate the webhook payload (JSON)
  def payload
    {
      event: {
        id: event.id,
        action: event.action,
        created_at: event.created_at.utc.iso8601,
        eventable_type: event.eventable_type,
        eventable_id: event.eventable_id,
        creator: {
          id: event.creator.id,
          name: event.creator.name
        },
        board: {
          id: event.board.id,
          name: event.board.name
        },
        particulars: event.particulars
      }
    }.to_json
  end

  # Generate HMAC-SHA256 signature for the payload
  def signature
    OpenSSL::HMAC.hexdigest("SHA256", webhook.signing_secret, payload)
  end

  # Enqueue delivery job
  def deliver_later
    Webhook::DeliveryJob.perform_later(self)
  end
end
