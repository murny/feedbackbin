# frozen_string_literal: true

require "test_helper"

class IdeaCommentMailerTest < ActionMailer::TestCase
  setup do
    Current.session = sessions(:shane_chrome)
    @comment = comments(:two)
    @comment.body = "Looks great, I love this idea!"
    @comment.save!
    @recipient = users(:jane)
    @mail = IdeaCommentMailer.with(comment: @comment, recipient: @recipient).new_comment
  end

  test "new_comment renders subject from i18n" do
    expected = I18n.t(
      "idea_comment_mailer.new_comment.subject",
      commenter: @comment.creator.name,
      title: @comment.idea.title
    )

    assert_equal expected, @mail.subject
  end

  test "new_comment delivers to the recipient identity email address" do
    assert_equal [ @recipient.identity.email_address ], @mail.to
  end

  test "new_comment body includes a link to the idea" do
    expected_path = Rails.application.routes.url_helpers.idea_path(@comment.idea, script_name: Current.account.slug)

    assert_match expected_path, @mail.body.encoded
  end

  test "new_comment body includes the comment text" do
    assert_match @comment.body.to_plain_text, @mail.body.encoded
  end
end
