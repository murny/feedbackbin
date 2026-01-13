# frozen_string_literal: true

require "test_helper"

class Notifier::IdeaEventNotifierTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    Watch.destroy_all
    Notification.destroy_all
  end

  test "idea_created notifies board creator when different from idea creator" do
    event = events(:idea_created)
    # Shane created the idea, board is created by someone else
    ideas(:one).board.update!(creator: users(:jane))

    notifications = Notifier.for(event).notify

    assert_equal 1, notifications.count
    assert_equal users(:jane), notifications.first.user
  end

  test "idea_created does not notify when idea creator is board creator" do
    event = events(:idea_created)
    ideas(:one).board.update!(creator: users(:shane))

    notifications = Notifier.for(event).notify

    assert_empty notifications
  end

  test "idea_status_changed notifies watchers" do
    # Jane is watching the idea
    ideas(:one).watch_by(users(:jane))
    ideas(:one).watch_by(users(:john))

    event = events(:idea_status_changed)

    notifications = Notifier.for(event).notify

    assert_equal 2, notifications.count
    assert_includes notifications.map(&:user), users(:jane)
    assert_includes notifications.map(&:user), users(:john)
  end

  test "idea_status_changed does not notify the person who made the change" do
    # Shane (the creator) is watching his own idea
    ideas(:one).watch_by(users(:shane))
    ideas(:one).watch_by(users(:jane))

    event = events(:idea_status_changed)
    # Shane made the change
    assert_equal users(:shane), event.creator

    notifications = Notifier.for(event).notify

    # Shane should not be notified
    assert_not_includes notifications.map(&:user), users(:shane)
    assert_includes notifications.map(&:user), users(:jane)
  end

  test "idea_board_changed notifies watchers" do
    ideas(:one).watch_by(users(:jane))

    event = events(:idea_board_changed)
    notifications = Notifier.for(event).notify

    assert_equal 1, notifications.count
    assert_equal users(:jane), notifications.first.user
  end

  test "idea_title_changed notifies watchers" do
    ideas(:one).watch_by(users(:jane))

    event = events(:idea_title_changed)
    notifications = Notifier.for(event).notify

    assert_equal 1, notifications.count
    assert_equal users(:jane), notifications.first.user
  end

  test "does not notify inactive users" do
    ideas(:one).watch_by(users(:jane))
    users(:jane).update!(active: false)

    event = events(:idea_status_changed)
    notifications = Notifier.for(event).notify

    assert_not_includes notifications.map(&:user), users(:jane)
  end

  test "does not notify system users" do
    ideas(:one).watch_by(users(:system))
    ideas(:one).watch_by(users(:jane))

    event = events(:idea_status_changed)
    notifications = Notifier.for(event).notify

    assert_not_includes notifications.map(&:user), users(:system)
    assert_includes notifications.map(&:user), users(:jane)
  end
end
