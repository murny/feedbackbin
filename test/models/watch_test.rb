# frozen_string_literal: true

require "test_helper"

class WatchTest < ActiveSupport::TestCase
  test "belongs to account" do
    watch = watches(:shane_watching_one)

    assert_equal accounts(:feedbackbin), watch.account
  end

  test "belongs to user" do
    watch = watches(:shane_watching_one)

    assert_equal users(:shane), watch.user
  end

  test "belongs to idea" do
    watch = watches(:shane_watching_one)

    assert_equal ideas(:one), watch.idea
  end

  test "account defaults to user's account" do
    watch = Watch.create!(user: users(:shane), idea: ideas(:two))

    assert_equal users(:shane).account, watch.account
  end

  test "watching scope returns only watching records" do
    Watch.destroy_all
    watching_watch = Watch.create!(user: users(:shane), idea: ideas(:one), watching: true)
    not_watching_watch = Watch.create!(user: users(:jane), idea: ideas(:one), watching: false)

    assert_includes Watch.watching, watching_watch
    assert_not_includes Watch.watching, not_watching_watch
  end

  test "not_watching scope returns only not-watching records" do
    Watch.destroy_all
    watching_watch = Watch.create!(user: users(:shane), idea: ideas(:one), watching: true)
    not_watching_watch = Watch.create!(user: users(:jane), idea: ideas(:one), watching: false)

    assert_not_includes Watch.not_watching, watching_watch
    assert_includes Watch.not_watching, not_watching_watch
  end

  test "unique index prevents duplicate user-idea watches" do
    watch = watches(:shane_watching_one)
    duplicate = Watch.new(user: watch.user, idea: watch.idea, account: watch.account)

    assert_raises ActiveRecord::RecordNotUnique do
      duplicate.save!(validate: false)
    end
  end
end
