# frozen_string_literal: true

require "test_helper"

class Webhook::TriggerableTest < ActiveSupport::TestCase
  test "triggered_by_action includes webhooks subscribed to that action" do
    active_webhook = webhooks(:active)

    results = Webhook.triggered_by_action("idea_created")

    assert_includes results, active_webhook
  end

  test "triggered_by_action excludes webhooks not subscribed to that action" do
    active_webhook = webhooks(:active)

    results = Webhook.triggered_by_action("idea_board_changed")

    assert_not_includes results, active_webhook
  end

  test "triggered_by returns webhooks subscribed to the event action from the same account and board" do
    event = events(:idea_created)
    active_webhook = webhooks(:active)

    assert_includes Webhook.triggered_by(event), active_webhook
  end

  test "triggered_by excludes webhooks from a different board" do
    event = events(:idea_created)
    inactive_webhook = webhooks(:inactive)

    assert_not_includes Webhook.triggered_by(event), inactive_webhook
  end

  test "triggered_by excludes webhooks from other accounts" do
    event = events(:idea_created)

    other_account = accounts(:acme)
    other_board = Board.create!(name: "Acme Board", color: "#000000", account: other_account, creator: users(:acme_admin))
    other_webhook = Webhook.create!(
      account: other_account,
      board: other_board,
      name: "Other Account Webhook",
      url: "https://other.example.com/hook",
      subscribed_actions: %w[idea_created]
    )

    assert_not_includes Webhook.triggered_by(event), other_webhook
  end

  test "trigger creates a delivery for the webhook" do
    webhook = webhooks(:active)
    event = events(:idea_created)

    assert_difference "Webhook::Delivery.count", 1 do
      webhook.trigger(event)
    end

    delivery = Webhook::Delivery.last

    assert_equal webhook, delivery.webhook
    assert_equal event, delivery.event
  end
end
