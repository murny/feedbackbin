# frozen_string_literal: true

require "test_helper"

class MentionTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
  end

  test "belongs to account" do
    mention = mentions(:idea_mention)
    assert_equal accounts(:feedbackbin), mention.account
  end

  test "belongs to source (idea)" do
    mention = mentions(:idea_mention)
    assert_equal ideas(:one), mention.source
  end

  test "belongs to source (comment)" do
    mention = mentions(:comment_mention)
    assert_equal comments(:one), mention.source
  end

  test "belongs to mentioner" do
    mention = mentions(:idea_mention)
    assert_equal users(:shane), mention.mentioner
  end

  test "belongs to mentionee" do
    mention = mentions(:idea_mention)
    assert_equal users(:jane), mention.mentionee
  end

  test "self_mention? returns true when mentioner equals mentionee" do
    mention = Mention.new(mentioner: users(:shane), mentionee: users(:shane))
    assert mention.self_mention?
  end

  test "self_mention? returns false when mentioner differs from mentionee" do
    mention = mentions(:idea_mention)
    assert_not mention.self_mention?
  end

  test "idea returns the idea for idea mentions" do
    mention = mentions(:idea_mention)
    assert_equal ideas(:one), mention.idea
  end

  test "idea returns the comment's idea for comment mentions" do
    mention = mentions(:comment_mention)
    assert_equal comments(:one).idea, mention.idea
  end

  test "auto-watches idea for mentionee on create" do
    Watch.destroy_all
    idea = ideas(:one)
    jane = users(:jane)

    assert_not idea.watched_by?(jane)

    Mention.create!(
      source: idea,
      mentioner: users(:shane),
      mentionee: jane
    )

    assert idea.watched_by?(jane)
  end

  test "validates uniqueness of mentionee per source" do
    mention = mentions(:idea_mention)
    duplicate = Mention.new(
      source: mention.source,
      mentioner: users(:john),
      mentionee: mention.mentionee
    )

    assert_not duplicate.valid?
  end
end
