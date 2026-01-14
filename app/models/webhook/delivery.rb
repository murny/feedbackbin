# frozen_string_literal: true

require "net/http"
require "openssl"

# Webhook::Delivery represents a single webhook delivery attempt.
# It handles:
# - Payload generation and signing (HMAC-SHA256)
# - HTTP request execution with SSRF protection
# - Response tracking
# - Error handling
#
# State machine:
#   pending -> in_progress -> completed (or errored)
#
# Security:
#   - SSRF protection blocks requests to private/internal IPs
#   - DNS resolution is pinned to prevent rebinding attacks
class Webhook::Delivery < ApplicationRecord
  include Rails.application.routes.url_helpers

  ENDPOINT_TIMEOUT = 7.seconds
  RETENTION_PERIOD = 30.days
  CLEANUP_BATCH_SIZE = 1000

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

  scope :stale, -> { where(created_at: ...RETENTION_PERIOD.ago) }

  # Automatically deliver webhook after creation
  after_create_commit :deliver_later

  # Delete old delivery records in batches to avoid locking
  def self.cleanup(batch_size: CLEANUP_BATCH_SIZE)
    loop do
      deleted = stale.limit(batch_size).delete_all
      break if deleted < batch_size
      sleep(0.1) # Small delay between batches
    end
  end

  # Deliver the webhook synchronously
  def deliver
    state_in_progress!

    self.request = { headers: headers, body: payload, url: webhook.url }
    self.response = perform_request
    self.state = :completed
    save!

    webhook.delinquency_tracker.record_delivery_of(self)
  rescue => error
    self.response = { error: error.class.name, message: error.message }
    state_errored!
    save!

    webhook.delinquency_tracker.record_delivery_of(self)
    raise
  end

  # Check if delivery succeeded
  def succeeded?
    state_completed? && response.present? && response["error"].blank? && response["code"]&.between?(200, 299)
  end

  # Check if delivery failed
  def failed?
    state_errored? || (state_completed? && !succeeded?)
  end

  private

    # Execute the HTTP request with SSRF protection
    def perform_request
      if resolved_ip.nil?
        { error: "private_uri" }
      else
        request = Net::HTTP::Post.new(uri.request_uri, headers)
        request.body = payload

        response = http.request(request)

        { code: response.code.to_i, body: response.body&.slice(0, 1000) }
      end
    rescue Resolv::ResolvTimeout, Resolv::ResolvError, SocketError
      { error: "dns_lookup_failed" }
    rescue Net::OpenTimeout, Net::ReadTimeout, Errno::ETIMEDOUT
      { error: "connection_timeout" }
    rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ECONNRESET
      { error: "destination_unreachable" }
    rescue OpenSSL::SSL::SSLError
      { error: "failed_tls" }
    end

    # Resolve and cache the public IP for the webhook URL
    # Returns nil if the hostname resolves to a private/blocked IP
    def resolved_ip
      return @resolved_ip if defined?(@resolved_ip)
      @resolved_ip = SsrfProtection.resolve_public_ip(uri.host)
    end

    # Parse and cache the webhook URL
    def uri
      @uri ||= URI(webhook.url)
    end

    # Build HTTP client with pinned IP to prevent DNS rebinding
    def http
      Net::HTTP.new(uri.host, uri.port).tap do |http|
        http.ipaddr = resolved_ip
        http.use_ssl = (uri.scheme == "https")
        http.open_timeout = ENDPOINT_TIMEOUT
        http.read_timeout = ENDPOINT_TIMEOUT
      end
    end

    # HTTP headers for the webhook request
    def headers
      {
        "Content-Type" => "application/json",
        "User-Agent" => "FeedbackBin-Webhook/1.0",
        "X-Webhook-Signature" => signature,
        "X-Webhook-Timestamp" => event.created_at.utc.iso8601
      }
    end

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
