# frozen_string_literal: true

require "test_helper"

class Idea::WatchableTest < ActiveSupport::TestCase
  setup do
    Watch.destroy_all
    Current.session = sessions(:shane_chrome)
  end

  test "watched_by? returns false for unwatched idea" do
    assert_not ideas(:one).watched_by?(users(:john))
  end

  test "watched_by? returns true after watching" do
    ideas(:one).watch_by(users(:john))

    assert ideas(:one).watched_by?(users(:john))
  end

  test "watched_by? returns false after unwatching" do
    ideas(:one).watch_by(users(:john))
    ideas(:one).unwatch_by(users(:john))

    assert_not ideas(:one).watched_by?(users(:john))
  end

  test "ideas are initially watched by their creator" do
    idea = boards(:one).ideas.create!(title: "Test idea", creator: users(:shane))

    assert idea.watched_by?(users(:shane))
  end

  test "watch_by creates a watch record" do
    assert_difference -> { Watch.count }, 1 do
      ideas(:one).watch_by(users(:john))
    end
  end

  test "watch_by updates existing watch record to watching" do
    ideas(:one).watch_by(users(:john))
    ideas(:one).unwatch_by(users(:john))

    assert_no_difference -> { Watch.count } do
      ideas(:one).watch_by(users(:john))
    end

    assert ideas(:one).watched_by?(users(:john))
  end

  test "unwatch_by updates existing watch record to not watching" do
    ideas(:one).watch_by(users(:john))

    assert_no_difference -> { Watch.count } do
      ideas(:one).unwatch_by(users(:john))
    end

    assert_not ideas(:one).watched_by?(users(:john))
  end

  test "unwatch_by creates a not-watching record if no watch exists" do
    assert_difference -> { Watch.count }, 1 do
      ideas(:one).unwatch_by(users(:john))
    end

    assert_not ideas(:one).watched_by?(users(:john))
  end

  test "watchers returns active users who are watching" do
    ideas(:one).watch_by(users(:jane))
    ideas(:one).watch_by(users(:john))
    ideas(:one).unwatch_by(users(:admin))

    watchers = ideas(:one).watchers.to_a

    assert_includes watchers, users(:jane)
    assert_includes watchers, users(:john)
    assert_not_includes watchers, users(:admin)
  end

  test "watchers excludes system users" do
    ideas(:one).watch_by(users(:system))
    ideas(:one).watch_by(users(:jane))

    watchers = ideas(:one).watchers.to_a

    assert_includes watchers, users(:jane)
    assert_not_includes watchers, users(:system)
  end

  test "watchers excludes deactivated users" do
    ideas(:one).watch_by(users(:jane))
    users(:jane).update!(active: false)

    watchers = ideas(:one).watchers.to_a

    assert_not_includes watchers, users(:jane)
  end

  test "watch_for returns nil when no watch exists" do
    assert_nil ideas(:one).watch_for(users(:john))
  end

  test "watch_for returns watch record when it exists" do
    ideas(:one).watch_by(users(:john))
    watch = ideas(:one).watch_for(users(:john))

    assert_instance_of Watch, watch
    assert_equal users(:john), watch.user
    assert_equal ideas(:one), watch.idea
  end
end
