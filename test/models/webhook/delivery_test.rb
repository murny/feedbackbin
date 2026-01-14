# frozen_string_literal: true

require "test_helper"

class Webhook::DeliveryTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "create" do
    webhook = webhooks(:active)
    event = events(:idea_created)

    delivery = Webhook::Delivery.create!(webhook: webhook, event: event)

    assert_equal "pending", delivery.state
  end

  test "succeeded?" do
    webhook = webhooks(:active)
    event = events(:idea_created)

    delivery = Webhook::Delivery.new(
      webhook: webhook,
      event: event,
      response: { "code" => 200 },
      state: :completed
    )

    assert_predicate delivery, :succeeded?

    delivery.response["code"] = 422

    assert_not delivery.succeeded?, "response must have a 2XX status"

    delivery.response["code"] = 200
    delivery.state = :pending

    assert_not delivery.succeeded?, "state must be completed"

    delivery.state = :in_progress

    assert_not delivery.succeeded?, "state must be completed"

    delivery.state = :errored

    assert_not delivery.succeeded?, "state must be completed"
  end

  test "failed?" do
    delivery = webhook_deliveries(:errored)

    assert_predicate delivery, :failed?

    delivery = webhook_deliveries(:unsuccessfully_completed)

    assert_predicate delivery, :failed?

    delivery = webhook_deliveries(:successfully_completed)

    assert_not delivery.failed?
  end

  test "enqueues delivery job after create" do
    webhook = webhooks(:active)
    event = events(:idea_created)

    assert_enqueued_with job: Webhook::DeliveryJob do
      Webhook::Delivery.create!(webhook: webhook, event: event)
    end
  end

  test "deliver" do
    delivery = webhook_deliveries(:pending)

    stub_request(:post, delivery.webhook.url)
      .to_return(status: 200, headers: { "content-type" => "application/json" })

    assert_equal "pending", delivery.state

    tracker = delivery.webhook.delinquency_tracker
    tracker.update!(consecutive_failures_count: 0)

    assert_no_difference -> { tracker.reload.consecutive_failures_count } do
      delivery.deliver
    end

    assert_predicate delivery, :persisted?
    assert_equal "completed", delivery.state
    assert_predicate delivery.request["headers"], :present?
    assert_equal 200, delivery.response["code"]
    assert_predicate delivery, :succeeded?
  end

  test "deliver when the network timeouts" do
    delivery = webhook_deliveries(:pending)
    stub_request(:post, delivery.webhook.url).to_timeout

    tracker = delivery.webhook.delinquency_tracker

    assert_difference -> { tracker.reload.consecutive_failures_count }, 1 do
      assert_raises(Net::OpenTimeout) do
        delivery.deliver
      end
    end

    assert_equal "errored", delivery.state
    assert_not delivery.succeeded?
  end

  test "deliver when the connection is refused" do
    delivery = webhook_deliveries(:pending)
    stub_request(:post, delivery.webhook.url).to_raise(Errno::ECONNREFUSED)

    assert_raises(Errno::ECONNREFUSED) do
      delivery.deliver
    end

    assert_equal "errored", delivery.state
    assert_predicate delivery.response["error"], :present?
  end

  test "deliver with slack webhook format" do
    webhook = webhooks(:slack)
    event = events(:idea_created)
    delivery = Webhook::Delivery.create!(webhook: webhook, event: event)

    request_stub = stub_request(:post, webhook.url)
      .with do |request|
        body = JSON.parse(request.body)
        body.key?("text") && body["text"].present? &&
        body["text"].include?("Open in FeedbackBin") &&
        request.headers["Content-Type"] == "application/json"
      end
      .to_return(status: 200)

    delivery.deliver

    assert_requested request_stub
    assert_predicate delivery, :succeeded?
  end

  test "deliver with generic webhook format" do
    webhook = webhooks(:active)
    event = events(:idea_created)
    delivery = Webhook::Delivery.create!(webhook: webhook, event: event)

    request_stub = stub_request(:post, webhook.url)
      .with do |request|
        body = JSON.parse(request.body)
        body.key?("event") && body["event"].key?("action") &&
        !body.key?("text") &&
        request.headers["Content-Type"] == "application/json"
      end
      .to_return(status: 200)

    delivery.deliver

    assert_requested request_stub
    assert_predicate delivery, :succeeded?
  end
end
