# frozen_string_literal: true

require "test_helper"

class Event::ParticularsTest < ActiveSupport::TestCase
  test "provides dynamic accessors for particulars" do
    event = events(:idea_status_changed)

    assert_respond_to event, :old_status
    assert_respond_to event, :new_status
    assert_equal "Open", event.old_status
    assert_equal "In Progress", event.new_status
  end

  test "does not respond to missing particulars keys" do
    event = events(:idea_created)

    assert_not event.respond_to?(:nonexistent_key)
  end

  test "raises NoMethodError for missing particulars keys" do
    event = events(:idea_created)

    assert_raises(NoMethodError) { event.nonexistent_key }
  end
end
