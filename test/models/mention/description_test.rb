# frozen_string_literal: true

require "test_helper"

class Mention::DescriptionTest < ActiveSupport::TestCase
  setup do
    @mention = mentions(:idea_mention)
    @user = users(:jane)
  end

  test "to_html includes mentioner name" do
    description = Mention::Description.new(@mention, @user)
    html = description.to_html

    assert_includes html, @mention.mentioner.name
  end

  test "to_html includes idea title" do
    description = Mention::Description.new(@mention, @user)
    html = description.to_html

    assert_includes html, @mention.idea.title
  end

  test "to_html includes mentioned_you_in text" do
    description = Mention::Description.new(@mention, @user)
    html = description.to_html

    assert_includes html, I18n.t("mentions.actions.mentioned_you_in")
  end

  test "to_plain_text returns readable string" do
    description = Mention::Description.new(@mention, @user)
    plain = description.to_plain_text

    assert_includes plain, @mention.mentioner.name
    assert_includes plain, @mention.idea.title
  end

  test "works with comment mentions" do
    comment_mention = mentions(:comment_mention)
    description = Mention::Description.new(comment_mention, users(:john))

    html = description.to_html

    assert_includes html, comment_mention.mentioner.name
    assert_includes html, comment_mention.idea.title
  end
end
