# frozen_string_literal: true

require "test_helper"

class Idea::WatchableTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    @idea = ideas(:one)
    @user = users(:shane)
  end

  test "watched_by? returns true when user is watching" do
    assert @idea.watched_by?(@user)
  end

  test "watched_by? returns false when user is not watching" do
    idea = ideas(:two)

    assert_not idea.watched_by?(@user)
  end

  test "watch_for returns watch record for user" do
    watch = @idea.watch_for(@user)

    assert_instance_of Watch, watch
    assert_equal @user, watch.user
  end

  test "watch_for returns nil when user has no watch" do
    idea = ideas(:two)

    assert_nil idea.watch_for(@user)
  end

  test "watch_by creates new watch when none exists" do
    idea = ideas(:two)

    assert_difference "Watch.count", 1 do
      idea.watch_by(@user)
    end

    assert idea.watched_by?(@user)
  end

  test "watch_by updates existing watch to watching" do
    @idea.unwatch_by(@user)

    assert_no_difference "Watch.count" do
      @idea.watch_by(@user)
    end

    assert @idea.watched_by?(@user)
  end

  test "unwatch_by sets watching to false" do
    @idea.unwatch_by(@user)

    assert_not @idea.watched_by?(@user)
    assert_not @idea.watch_for(@user).watching?
  end

  test "unwatch_by creates watch with watching false if none exists" do
    idea = ideas(:two)

    assert_difference "Watch.count", 1 do
      idea.unwatch_by(@user)
    end

    assert_not idea.watched_by?(@user)
  end

  test "watchers returns only active watching users" do
    watchers = @idea.watchers

    assert_includes watchers, @user
    assert_includes watchers, users(:jane)
  end

  test "creator is auto-subscribed on idea creation" do
    idea = Idea.create!(
      title: "New idea",
      board: boards(:one),
      creator: @user
    )

    assert idea.watched_by?(@user)
  end
end
