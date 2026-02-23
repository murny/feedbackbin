# frozen_string_literal: true

require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "valid tag" do
    tag = Tag.new(title: "enhancement", account: accounts(:feedbackbin))

    assert_predicate tag, :valid?
  end

  test "invalid without title" do
    tag = Tag.new(account: accounts(:feedbackbin))

    assert_not tag.valid?
    assert_predicate tag.errors[:title], :present?
  end

  test "title must be unique per account" do
    existing = tags(:feature)
    duplicate = Tag.new(title: existing.title, account: existing.account)

    assert_not duplicate.valid?
    assert_predicate duplicate.errors[:title], :present?
  end

  test "same title is allowed across different accounts" do
    tag = Tag.new(title: tags(:feature).title, account: accounts(:acme))

    assert_predicate tag, :valid?
  end

  test "title cannot start with a hash symbol" do
    tag = Tag.new(title: "#feature", account: accounts(:feedbackbin))

    assert_not tag.valid?
    assert_predicate tag.errors[:title], :present?
  end

  test "normalizes title to lowercase and strips whitespace" do
    tag = Tag.create!(title: "  BugFix  ", account: accounts(:feedbackbin))

    assert_equal "bugfix", tag.title
  end

  test "hashtag returns title prefixed with hash symbol" do
    tag = tags(:feature)

    assert_equal "##{tag.title}", tag.hashtag
  end

  test "alphabetically scope orders tags case-insensitively" do
    account = accounts(:feedbackbin)
    Tag.create!(title: "zebra", account: account)
    Tag.create!(title: "alpha", account: account)

    titles = account.tags.alphabetically.pluck(:title)

    assert_equal titles, titles.sort_by(&:downcase)
  end

  test "unused scope returns tags with no taggings" do
    account = accounts(:feedbackbin)
    tag_without_tagging = Tag.create!(title: "unused-tag", account: account)
    tag_with_tagging = Tag.create!(title: "used-tag", account: account)
    Tagging.create!(tag: tag_with_tagging, idea: ideas(:one), account: account)

    assert_includes Tag.unused, tag_without_tagging
    assert_not_includes Tag.unused, tag_with_tagging
  end
end
