# frozen_string_literal: true

class IdeaCommentMailer < ApplicationMailer
  def new_comment
    @comment = params.fetch(:comment)
    @recipient = params.fetch(:recipient)
    @idea = @comment.idea
    @commenter = @comment.creator

    mail(
      to: @recipient.identity.email_address,
      subject: t(".subject", commenter: @commenter.name, title: @idea.title)
    )
  end
end
