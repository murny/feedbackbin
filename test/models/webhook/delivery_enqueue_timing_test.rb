# frozen_string_literal: true

require "test_helper"

class Webhook::DeliveryEnqueueTimingTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  self.use_transactional_tests = false

  setup do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  teardown do
    clear_enqueued_jobs
    clear_performed_jobs
  end

  test "enqueues delivery job only after commit" do
    webhook = webhooks(:active)
    event = events(:idea_created)
    delivery = nil

    Webhook::Delivery.transaction do
      delivery = Webhook::Delivery.create!(webhook: webhook, event: event)

      assert_no_enqueued_jobs only: Webhook::DeliveryJob
    end

    assert_enqueued_jobs 1, only: Webhook::DeliveryJob
    delivery.destroy!
  end

  test "does not enqueue delivery job when transaction rolls back" do
    webhook = webhooks(:active)
    event = events(:idea_created)

    assert_no_enqueued_jobs only: Webhook::DeliveryJob do
      Webhook::Delivery.transaction do
        Webhook::Delivery.create!(webhook: webhook, event: event)
        raise ActiveRecord::Rollback
      end
    end
  end
end
