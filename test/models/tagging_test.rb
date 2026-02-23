# frozen_string_literal: true

require "test_helper"

class TaggingTest < ActiveSupport::TestCase
  setup do
    @idea = ideas(:one)
    @tag = tags(:feature)
    @account = accounts(:feedbackbin)
  end

  test "valid tagging" do
    tagging = Tagging.new(idea: @idea, tag: @tag, account: @account)

    assert_predicate tagging, :valid?
  end

  test "invalid without idea" do
    tagging = Tagging.new(tag: @tag, account: @account)

    assert_not tagging.valid?
    assert_predicate tagging.errors[:idea], :present?
  end

  test "invalid without tag" do
    tagging = Tagging.new(idea: @idea, account: @account)

    assert_not tagging.valid?
    assert_predicate tagging.errors[:tag], :present?
  end

  test "tag_id must be unique per idea" do
    Tagging.create!(idea: @idea, tag: @tag, account: @account)
    duplicate = Tagging.new(idea: @idea, tag: @tag, account: @account)

    assert_not duplicate.valid?
    assert_predicate duplicate.errors[:tag_id], :present?
  end

  test "same tag can be applied to different ideas" do
    Tagging.create!(idea: @idea, tag: @tag, account: @account)
    another_tagging = Tagging.new(idea: ideas(:two), tag: @tag, account: @account)

    assert_predicate another_tagging, :valid?
  end

  test "account is inherited from idea when not explicitly set" do
    tagging = Tagging.create!(idea: @idea, tag: @tag)

    assert_equal @idea.account, tagging.account
  end
end
