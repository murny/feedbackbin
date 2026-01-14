# frozen_string_literal: true

require "test_helper"

class WebhookTest < ActiveSupport::TestCase
  test "create" do
    webhook = Webhook.create!(
      name: "Test",
      url: "https://example.com/webhook",
      account: accounts(:feedbackbin),
      board: boards(:one),
      subscribed_actions: %w[idea_created]
    )

    assert_predicate webhook, :persisted?
    assert_predicate webhook, :active?
    assert_predicate webhook.signing_secret, :present?
    assert_predicate webhook.delinquency_tracker, :present?
  end

  test "validates the url" do
    webhook = Webhook.new(name: "Test", account: accounts(:feedbackbin), board: boards(:one), subscribed_actions: %w[idea_created])

    assert_not webhook.valid?
    assert_predicate webhook.errors[:url], :present?

    webhook = Webhook.new(name: "Test", account: accounts(:feedbackbin), board: boards(:one), subscribed_actions: %w[idea_created], url: "not a url")

    assert_not webhook.valid?
    assert_predicate webhook.errors[:url], :present?

    webhook = Webhook.new(name: "HTTP", account: accounts(:feedbackbin), board: boards(:one), subscribed_actions: %w[idea_created], url: "http://example.com/webhook")

    assert_predicate webhook, :valid?

    webhook = Webhook.new(name: "HTTPS", account: accounts(:feedbackbin), board: boards(:one), subscribed_actions: %w[idea_created], url: "https://example.com/webhook")

    assert_predicate webhook, :valid?
  end

  test "normalizes subscribed_actions" do
    webhook = Webhook.new(
      name: "Test",
      url: "https://example.com/webhook",
      account: accounts(:feedbackbin),
      board: boards(:one),
      subscribed_actions: [ "", "idea_created", "invalid_action", "idea_created" ]
    )

    # Should filter out empty strings, invalid actions, and duplicates
    assert_equal %w[idea_created], webhook.subscribed_actions
  end

  test "deactivate" do
    webhook = webhooks(:active)

    assert_changes -> { webhook.active? }, from: true, to: false do
      webhook.deactivate
    end
  end

  test "activate" do
    webhook = webhooks(:inactive)

    assert_changes -> { webhook.active? }, from: false, to: true do
      webhook.activate
    end
  end

  test "for_slack?" do
    webhook = Webhook.new(url: "https://hooks.slack.com/services/T12345678/B12345678/abcdefghijklmnopqrstuvwx")

    assert_predicate webhook, :for_slack?

    webhook = Webhook.new(url: "https://hooks.slack.com/services/T12345678/B12345678")

    assert_not webhook.for_slack?

    webhook = Webhook.new(url: "https://hooks.slack.com/services/T12345678")

    assert_not webhook.for_slack?

    webhook = Webhook.new(url: "https://hooks.slack.com/services/")

    assert_not webhook.for_slack?

    webhook = Webhook.new(url: "https://example.com/webhook")

    assert_not webhook.for_slack?
  end

  test "subscribed_to?" do
    webhook = webhooks(:active)

    assert webhook.subscribed_to?(:idea_created)
    assert webhook.subscribed_to?("idea_created")
    assert_not webhook.subscribed_to?(:idea_board_changed)
  end
end
