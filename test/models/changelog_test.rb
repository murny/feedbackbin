require "test_helper"

class ChangelogTest < ActiveSupport::TestCase
  test "unread? returns false for guest when no changelogs" do
    assert Changelog.unread?(nil)
  end

  test "unread? returns true for guest" do
    assert Changelog.unread?(nil)
  end

  test "unread? returns false when no changelogs and never read" do
    user = users(:user)
    user.update(changelogs_read_at: nil)
    Changelog.delete_all

    assert_not Changelog.unread?(user)
  end

  test "unread? returns false when no changelogs" do
    user = users(:user)
    user.update(changelogs_read_at: 1.month.ago)
    Changelog.delete_all

    assert_not Changelog.unread?(user)
  end

  test "unread? returns true with unread changelogs" do
    user = users(:user)
    user.update(changelogs_read_at: Changelog.maximum(:published_at) - 1.month)

    assert Changelog.unread?(user)
  end

  test "unread? returns false with no unread changelogs" do
    user = users(:user)
    user.update(changelogs_read_at: Changelog.maximum(:published_at) + 1.month)

    assert_not Changelog.unread?(user)
  end
end
