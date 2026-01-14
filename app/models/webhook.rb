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

  has_secure_token :signing_secret

  belongs_to :account, default: -> { Current.account }
  belongs_to :board, optional: true

  has_many :deliveries, class_name: "Webhook::Delivery", dependent: :destroy

  validates :name, presence: true
  validates :url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid HTTP(S) URL" }
  validates :subscribed_actions, presence: true
  validate :subscribed_actions_are_permitted

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

  private

    def subscribed_actions_are_permitted
      return if subscribed_actions.blank?

      invalid_actions = subscribed_actions - PERMITTED_ACTIONS
      if invalid_actions.any?
        errors.add(:subscribed_actions, "contains invalid actions: #{invalid_actions.join(', ')}")
      end
    end
end
