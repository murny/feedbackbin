# frozen_string_literal: true

# Webhook represents a webhook subscription for an account.
# When events occur that match the subscribed_actions, webhook deliveries are created.
#
# Example:
#   webhook = Webhook.create!(
#     account: account,
#     name: "Slack Notifications",
#     url: "https://hooks.slack.com/services/...",
#     subscribed_actions: ["idea_created", "idea_status_changed", "comment_created"]
#   )
#
# Security:
#   - Each webhook has a unique signing_secret
#   - Payloads are signed with HMAC-SHA256
#   - Receivers can verify authenticity using the signature
class Webhook < ApplicationRecord
  include Webhook::Triggerable

  # All possible event actions that can be subscribed to
  PERMITTED_ACTIONS = %w[
    idea_created
    idea_status_changed
    idea_board_changed
    idea_title_changed
    comment_created
  ].freeze

  # Slack incoming webhook URL pattern
  SLACK_WEBHOOK_URL_REGEX = %r{//hooks\.slack\.com/services/T[^/]+/B[^/]+/[^/]+\z}i

  has_secure_token :signing_secret

  belongs_to :account, default: -> { Current.account }
  belongs_to :board, optional: true

  has_many :deliveries, class_name: "Webhook::Delivery", dependent: :destroy
  has_one :delinquency_tracker, class_name: "Webhook::DelinquencyTracker", dependent: :destroy

  after_create :create_delinquency_tracker!

  normalizes :subscribed_actions, with: ->(value) { Array.wrap(value).map(&:to_s).uniq & PERMITTED_ACTIONS }

  validates :name, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid HTTP(S) URL" }
  validates :subscribed_actions, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }

  # Activate the webhook
  def activate
    update(active: true)
  end

  # Deactivate the webhook
  def deactivate
    update(active: false)
  end

  # Check if webhook is subscribed to a specific action
  def subscribed_to?(action)
    subscribed_actions.include?(action.to_s)
  end

  # Check if webhook URL is a Slack incoming webhook
  def for_slack?
    url.match?(SLACK_WEBHOOK_URL_REGEX)
  end
end
