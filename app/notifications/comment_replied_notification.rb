# frozen_string_literal: true

# Notification sent when someone replies to your comment
class CommentRepliedNotification < Noticed::Event
  deliver_by :database

  # Params:
  # - comment: The reply comment
  # - parent_comment: The parent comment being replied to
  # - replier: The user who created the reply
  # - post: The post containing the comment thread

  # Notify the parent comment's creator
  def notification_recipients
    parent_comment = params[:parent_comment]
    replier = params[:replier]

    return User.none unless parent_comment && replier

    # Notify parent comment creator, but not if they're replying to themselves
    parent_creator = parent_comment.creator
    return User.none if parent_creator == replier

    [ parent_creator ]
  end

  def url
    post = params[:post]
    comment = params[:comment]
    return unless post && comment

    Rails.application.routes.url_helpers.post_path(post, anchor: "comment_#{comment.id}")
  end

  def message
    replier_name = params[:replier]&.name || "Someone"

    "#{replier_name} replied to your comment"
  end
end
