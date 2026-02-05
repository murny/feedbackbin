# frozen_string_literal: true

require "test_helper"

class MentioningTest < ActiveSupport::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    Mention.destroy_all
  end

  test "idea has mentions association" do
    idea = ideas(:one)

    assert_respond_to idea, :mentions
  end

  test "comment has mentions association" do
    comment = comments(:one)

    assert_respond_to comment, :mentions
  end

  test "creates mentions when rich text contains user attachments" do
    idea = ideas(:one)
    jane = users(:jane)

    rich_text_with_mention = <<~HTML
      <div>Hello <action-text-attachment sgid="#{jane.attachable_sgid}"></action-text-attachment>!</div>
    HTML

    idea.update!(description: rich_text_with_mention)

    assert_equal 1, idea.mentions.count
    assert_equal jane, idea.mentions.first.mentionee
    assert_equal idea.creator, idea.mentions.first.mentioner
  end

  test "removes mentions when user is removed from rich text" do
    idea = ideas(:one)
    jane = users(:jane)
    john = users(:john)

    rich_text_with_two_mentions = <<~HTML
      <div>
        Hello <action-text-attachment sgid="#{jane.attachable_sgid}"></action-text-attachment>
        and <action-text-attachment sgid="#{john.attachable_sgid}"></action-text-attachment>!
      </div>
    HTML

    idea.update!(description: rich_text_with_two_mentions)

    assert_equal 2, idea.mentions.count

    rich_text_with_one_mention = <<~HTML
      <div>Hello <action-text-attachment sgid="#{jane.attachable_sgid}"></action-text-attachment>!</div>
    HTML

    idea.update!(description: rich_text_with_one_mention)

    assert_equal 1, idea.mentions.count
    assert_equal jane, idea.mentions.first.mentionee
  end

  test "does not create duplicate mentions for same user" do
    idea = ideas(:one)
    jane = users(:jane)

    rich_text_with_duplicate_mentions = <<~HTML
      <div>
        Hello <action-text-attachment sgid="#{jane.attachable_sgid}"></action-text-attachment>
        and again <action-text-attachment sgid="#{jane.attachable_sgid}"></action-text-attachment>!
      </div>
    HTML

    idea.update!(description: rich_text_with_duplicate_mentions)

    assert_equal 1, idea.mentions.count
  end

  test "comment mentions work correctly" do
    comment = comments(:one)
    john = users(:john)

    rich_text_with_mention = <<~HTML
      <div>Thanks <action-text-attachment sgid="#{john.attachable_sgid}"></action-text-attachment>!</div>
    HTML

    comment.update!(body: rich_text_with_mention)

    assert_equal 1, comment.mentions.count
    assert_equal john, comment.mentions.first.mentionee
  end

  test "destroying source destroys associated mentions" do
    idea = ideas(:one)
    jane = users(:jane)

    rich_text_with_mention = <<~HTML
      <div>Hello <action-text-attachment sgid="#{jane.attachable_sgid}"></action-text-attachment>!</div>
    HTML

    idea.update!(description: rich_text_with_mention)
    mention_id = idea.mentions.first.id

    idea.destroy!

    assert_nil Mention.find_by(id: mention_id)
  end

  test "removes all mentions when rich text is cleared" do
    idea = ideas(:one)
    jane = users(:jane)

    rich_text_with_mention = <<~HTML
      <div>Hello <action-text-attachment sgid="#{jane.attachable_sgid}"></action-text-attachment>!</div>
    HTML

    idea.update!(description: rich_text_with_mention)

    assert_equal 1, idea.mentions.count

    idea.update!(description: "")

    assert_equal 0, idea.mentions.count
  end
end
