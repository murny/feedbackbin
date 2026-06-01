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

  test "internal-comment mention to non-staff returns no recipients" do
    comment = comments(:two)
    comment.update!(internal: true)

    mention = Mention.create!(
      account: accounts(:feedbackbin),
      source: comment,
      mentioner: users(:shane),
      mentionee: users(:john) # member role
    )

    notifications = Notifier.for(mention).notify

    assert_empty notifications
  end

  test "internal-comment mention to admin returns the admin as recipient" do
    comment = comments(:two)
    comment.update!(internal: true)

    mention = Mention.create!(
      account: accounts(:feedbackbin),
      source: comment,
      mentioner: users(:shane),
      mentionee: users(:admin)
    )

    notifications = Notifier.for(mention).notify

    assert_equal [ users(:admin) ], notifications.map(&:user)
  end

  test "public-comment mention notifies mentionee (regression)" do
    comment = comments(:two)

    refute comment.internal

    mention = Mention.create!(
      account: accounts(:feedbackbin),
      source: comment,
      mentioner: users(:shane),
      mentionee: users(:john)
    )

    notifications = Notifier.for(mention).notify

    assert_equal [ users(:john) ], notifications.map(&:user)
  end

  test "mention whose source is not a Comment is unaffected by internal-comment guard" do
    # Idea-source mention with a non-staff mentionee
    mention = mentions(:idea_mention)

    notifications = Notifier.for(mention).notify

    assert_equal [ mention.mentionee ], notifications.map(&:user)
  end
end
