# frozen_string_literal: true

require "test_helper"

class Notifier::MentionNotifierTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    Notification.destroy_all
  end

  test "notifies mentionee when mentioned" do
    mention = mentions(:idea_mention)

    notifications = Notifier.for(mention).notify

    assert_equal 1, notifications.count
    assert_equal users(:jane), notifications.first.user
    assert_equal users(:shane), notifications.first.creator
  end

  test "does not notify for self-mentions" do
    mention = Mention.new(
      account: accounts(:feedbackbin),
      source: ideas(:one),
      mentioner: users(:shane),
      mentionee: users(:shane)
    )
    mention.save(validate: false)

    notifications = Notifier.for(mention).notify

    assert_empty notifications
  end

  test "notification has correct source" do
    mention = mentions(:idea_mention)

    notifications = Notifier.for(mention).notify

    assert_equal mention, notifications.first.source
  end
end
