# frozen_string_literal: true

require "test_helper"

class ChangelogTest < ActiveSupport::TestCase
  setup do
    @changelog = changelogs(:one)
  end

  test "valid changelog" do
    assert_predicate @changelog, :valid?
  end

  test "invalid without title" do
    @changelog.title = nil

    assert_not @changelog.valid?
    assert_equal "can't be blank", @changelog.errors[:title].first
  end

  test "invalid without description" do
    @changelog.description = nil

    assert_not @changelog.valid?
    assert_equal "can't be blank", @changelog.errors[:description].first
  end

  test "invalid without a kind" do
    @changelog.kind = nil

    assert_not @changelog.valid?
    assert_equal "can't be blank", @changelog.errors[:kind].first
  end

  test "invalid with an incorrect kind" do
    @changelog.kind = "invalid"

    assert_not @changelog.valid?
    assert_equal "is not included in the list", @changelog.errors[:kind].first
  end

  test "invalid without an account" do
    @changelog.account = nil

    assert_not @changelog.valid?
    assert_equal "must exist", @changelog.errors[:account].first
  end

  test "unread? returns false for guest when no changelogs" do
    Changelog.delete_all

    assert_not Changelog.unread?(nil)
  end

  test "unread? returns true for guest" do
    assert Changelog.unread?(nil)
  end

  test "unread? returns false when no changelogs and never read" do
    user = users(:one)
    user.update(changelogs_read_at: nil)
    Changelog.delete_all

    assert_not Changelog.unread?(user)
  end

  test "unread? returns false when no changelogs" do
    user = users(:one)
    user.update(changelogs_read_at: 1.month.ago)
    Changelog.delete_all

    assert_not Changelog.unread?(user)
  end

  test "unread? returns true with unread changelogs" do
    user = users(:one)
    user.update(changelogs_read_at: Changelog.maximum(:published_at) - 1.month)

    assert Changelog.unread?(user)
  end

  test "unread? returns false with no unread changelogs" do
    user = users(:one)
    user.update(changelogs_read_at: Changelog.maximum(:published_at) + 1.month)

    assert_not Changelog.unread?(user)
  end
end
