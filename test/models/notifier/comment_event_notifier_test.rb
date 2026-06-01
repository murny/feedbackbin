# frozen_string_literal: true

require "test_helper"

class Notifier::CommentEventNotifierTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    Watch.destroy_all
    Notification.destroy_all
  end

  test "comment_created notifies idea watchers" do
    # Shane and Jane are watching the idea
    ideas(:one).watch_by(users(:shane))
    ideas(:one).watch_by(users(:jane))

    event = events(:comment_created)
    # The comment was created by John
    event.eventable.update!(creator: users(:john))
    event.update!(creator: users(:john))

    notifications = Notifier.for(event).notify

    assert_equal 2, notifications.count
    assert_includes notifications.map(&:user), users(:shane)
    assert_includes notifications.map(&:user), users(:jane)
  end

  test "comment_created does not notify the commenter" do
    # Jane is watching and created the comment
    ideas(:one).watch_by(users(:jane))
    ideas(:one).watch_by(users(:john))

    event = events(:comment_created)
    event.eventable.update!(creator: users(:jane))
    event.update!(creator: users(:jane))

    notifications = Notifier.for(event).notify

    assert_not_includes notifications.map(&:user), users(:jane)
    assert_includes notifications.map(&:user), users(:john)
  end

  test "does not notify inactive users" do
    ideas(:one).watch_by(users(:jane))
    users(:jane).update!(active: false)

    event = events(:comment_created)
    notifications = Notifier.for(event).notify

    assert_not_includes notifications.map(&:user), users(:jane)
  end

  test "does not notify system users" do
    ideas(:one).watch_by(users(:system))
    ideas(:one).watch_by(users(:shane))

    event = events(:comment_created)
    # Jane created the event, so Shane should be notified but not system user
    assert_equal users(:jane), event.creator

    notifications = Notifier.for(event).notify

    assert_not_includes notifications.map(&:user), users(:system)
    assert_includes notifications.map(&:user), users(:shane)
  end

  test "auto-watches idea when user comments" do
    Current.session = sessions(:shane_chrome)
    Watch.destroy_all

    assert_not ideas(:one).watched_by?(users(:jane))

    # Jane comments on the idea
    Comment.create!(
      idea: ideas(:one),
      creator: users(:jane),
      body: "Great idea!"
    )

    assert ideas(:one).watched_by?(users(:jane))
  end

  test "internal comment_created excludes non-staff watchers" do
    ideas(:one).watch_by(users(:john)) # member-role watcher

    event = events(:comment_created)
    event.eventable.update!(internal: true)

    notifications = Notifier.for(event).notify

    assert_not_includes notifications.map(&:user), users(:john)
  end

  test "internal comment_created notifies admin watcher" do
    ideas(:one).watch_by(users(:admin))

    event = events(:comment_created)
    event.eventable.update!(internal: true)

    notifications = Notifier.for(event).notify

    assert_includes notifications.map(&:user), users(:admin)
  end

  test "internal comment_created notifies owner watcher" do
    ideas(:one).watch_by(users(:shane)) # owner role

    event = events(:comment_created)
    event.eventable.update!(internal: true)

    notifications = Notifier.for(event).notify

    assert_includes notifications.map(&:user), users(:shane)
  end

  test "public comment_created still notifies non-staff watchers (regression)" do
    ideas(:one).watch_by(users(:john)) # member-role watcher

    event = events(:comment_created)

    refute event.eventable.internal

    notifications = Notifier.for(event).notify

    assert_includes notifications.map(&:user), users(:john)
  end
end
