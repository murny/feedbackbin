# frozen_string_literal: true

# Notification sent when someone comments on a post
class PostCommentedNotification < Noticed::Event
  deliver_by :database

  # Params:
  # - post: The post that was commented on
  # - comment: The comment that was created
  # - commenter: The user who created the comment

  # Notify all active subscribers of the post except the commenter
  def notification_recipients
    post = params[:post]
    comment = params[:comment]
    commenter = params[:commenter]

    return User.none unless post && comment && commenter

    post.active_subscribers.where.not(id: commenter.id)
  end

  def url
    post = params[:post]
    comment = params[:comment]
    return unless post && comment

    Rails.application.routes.url_helpers.post_path(post, anchor: "comment_#{comment.id}")
  end

  def message
    commenter_name = params[:commenter]&.name || "Someone"
    post_title = params[:post]&.title || "a post"

    "#{commenter_name} commented on #{post_title}"
  end
end
