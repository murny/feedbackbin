# frozen_string_literal: true

# Webhook::DelinquencyTracker monitors webhook delivery success/failure patterns.
# When a webhook experiences too many consecutive failures within a time window,
# it is automatically deactivated to prevent continued failed delivery attempts.
#
# Thresholds:
#   - DELINQUENCY_THRESHOLD: Number of consecutive failures required
#   - DELINQUENCY_DURATION: Time window since first failure
#
# Both conditions must be met for automatic deactivation.
class Webhook::DelinquencyTracker < ApplicationRecord
  DELINQUENCY_THRESHOLD = 10
  DELINQUENCY_DURATION = 1.hour

  belongs_to :account, default: -> { webhook.account }
  belongs_to :webhook

  # Record a delivery result and update failure tracking
  def record_delivery_of(delivery)
    if delivery.succeeded?
      reset
    else
      mark_first_failure_time if consecutive_failures_count.zero?
      increment!(:consecutive_failures_count, touch: true)

      webhook.deactivate if delinquent?
    end
  end

  private

    def reset
      update_columns consecutive_failures_count: 0, first_failure_at: nil
    end

    def mark_first_failure_time
      update_columns first_failure_at: Time.current
    end

    def delinquent?
      failing_for_too_long? && too_many_consecutive_failures?
    end

    def failing_for_too_long?
      if first_failure_at
        first_failure_at.before?(DELINQUENCY_DURATION.ago)
      else
        false
      end
    end

    def too_many_consecutive_failures?
      consecutive_failures_count >= DELINQUENCY_THRESHOLD
    end
end
