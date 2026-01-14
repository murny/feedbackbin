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
  include Rails.application.routes.url_helpers

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

    webhook.delinquency_tracker.record_delivery_of(self)
  rescue => error
    # Store error details
    self.response = {
      error: error.class.name,
      message: error.message
    }

    state_errored!
    save!

    webhook.delinquency_tracker.record_delivery_of(self)
    raise
  end

  # Check if delivery succeeded
  def succeeded?
    state_completed? && response.present? && response["code"]&.between?(200, 299)
  end

  # Check if delivery failed
  def failed?
    state_errored? || (state_completed? && !succeeded?)
  end

  private

    # Generate the webhook payload (JSON)
    def payload
      @payload ||= webhook.for_slack? ? slack_payload : default_payload
    end

    # Default JSON payload with full event data
    def default_payload
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

    # Slack-friendly payload with mrkdwn formatting
    def slack_payload
      text = event.description_for(nil).to_plain_text
      url = idea_url(idea, default_url_options)

      { text: "#{text} <#{url}|Open in FeedbackBin>" }.to_json
    end

    # Get the idea from the event (handles both ideas and comments)
    def idea
      event.action.comment_created? ? event.eventable.idea : event.eventable
    end

    # Default URL options for generating links
    def default_url_options
      Rails.application.routes.default_url_options.presence ||
        Rails.application.config.action_mailer.default_url_options
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
