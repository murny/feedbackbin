# frozen_string_literal: true

require "test_helper"

class NotifierTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    Watch.destroy_all
    Notification.destroy_all
  end

  test "for returns IdeaEventNotifier for Idea events" do
    event = events(:idea_created)
    notifier = Notifier.for(event)

    assert_kind_of Notifier::IdeaEventNotifier, notifier
  end

  test "for returns CommentEventNotifier for Comment events" do
    event = events(:comment_created)
    notifier = Notifier.for(event)

    assert_kind_of Notifier::CommentEventNotifier, notifier
  end

  test "for returns nil for unknown source types" do
    assert_nil Notifier.for("unknown")
  end

  test "does not create notifications if the event was created by system user" do
    event = events(:idea_created)
    event.update!(creator: users(:system))

    assert_no_difference -> { Notification.count } do
      Notifier.for(event).notify
    end
  end

  test "sorts recipients by ID to prevent deadlocks" do
    # Set up watchers in a specific order
    ideas(:one).watch_by(users(:john))
    ideas(:one).watch_by(users(:jane))

    event = events(:idea_status_changed)
    notifier = Notifier.for(event)
    notifications = notifier.notify

    # Notifications should be created in ID order
    user_ids = notifications.map { |n| n.user.id }

    assert_equal user_ids.sort, user_ids
  end
end
