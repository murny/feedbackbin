# frozen_string_literal: true

require "test_helper"

class Webhook::DelinquencyTrackerTest < ActiveSupport::TestCase
  test "record_delivery_of resets on success" do
    tracker = webhook_delinquency_trackers(:active_webhook_tracker)
    successful_delivery = webhook_deliveries(:successfully_completed)

    tracker.update!(consecutive_failures_count: 5, first_failure_at: 1.hour.ago)
    tracker.record_delivery_of(successful_delivery)
    tracker.reload

    assert_equal 0, tracker.consecutive_failures_count
    assert_nil tracker.first_failure_at
  end

  test "record_delivery_of increments failures on failure" do
    tracker = webhook_delinquency_trackers(:active_webhook_tracker)
    failed_delivery = webhook_deliveries(:errored)

    tracker.update!(consecutive_failures_count: 0, first_failure_at: nil)

    assert_difference -> { tracker.reload.consecutive_failures_count }, +1 do
      tracker.record_delivery_of(failed_delivery)
    end

    tracker.reload

    assert_not_nil tracker.first_failure_at
  end

  test "record_delivery_of does not update first_failure_at on subsequent failures" do
    tracker = webhook_delinquency_trackers(:active_webhook_tracker)
    failed_delivery = webhook_deliveries(:errored)

    original_time = 30.minutes.ago
    tracker.update!(consecutive_failures_count: 3, first_failure_at: original_time)

    assert_difference -> { tracker.reload.consecutive_failures_count }, +1 do
      assert_no_changes -> { tracker.reload.first_failure_at.to_i } do
        tracker.record_delivery_of(failed_delivery)
      end
    end
  end

  test "record_delivery_of deactivates webhook when delinquent" do
    tracker = webhook_delinquency_trackers(:active_webhook_tracker)
    webhook = tracker.webhook
    failed_delivery = webhook_deliveries(:errored)

    travel_to 2.hours.from_now do
      tracker.update!(consecutive_failures_count: 9, first_failure_at: 2.hours.ago)
      webhook.activate

      assert_changes -> { webhook.reload.active? }, from: true, to: false do
        tracker.record_delivery_of(failed_delivery)
      end
    end
  end

  test "record_delivery_of does not deactivate if not enough failures" do
    tracker = webhook_delinquency_trackers(:active_webhook_tracker)
    webhook = tracker.webhook
    failed_delivery = webhook_deliveries(:errored)

    travel_to 2.hours.from_now do
      tracker.update!(consecutive_failures_count: 5, first_failure_at: 2.hours.ago)
      webhook.activate

      assert_no_changes -> { webhook.reload.active? } do
        tracker.record_delivery_of(failed_delivery)
      end
    end
  end

  test "record_delivery_of does not deactivate if not enough time elapsed" do
    tracker = webhook_delinquency_trackers(:active_webhook_tracker)
    webhook = tracker.webhook
    failed_delivery = webhook_deliveries(:errored)

    tracker.update!(consecutive_failures_count: 9, first_failure_at: 30.minutes.ago)
    webhook.activate

    assert_no_changes -> { webhook.reload.active? } do
      tracker.record_delivery_of(failed_delivery)
    end
  end
end
