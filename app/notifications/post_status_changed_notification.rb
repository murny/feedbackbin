# frozen_string_literal: true

# Notification sent when a post's status changes
class PostStatusChangedNotification < Noticed::Event
  deliver_by :database

  # Params:
  # - post: The post whose status changed
  # - old_status: The previous PostStatus
  # - new_status: The new PostStatus
  # - changed_by: The user who changed the status

  # Notify all active subscribers and users who upvoted the post
  def notification_recipients
    post = params[:post]
    changed_by = params[:changed_by]

    return User.none unless post && changed_by

    # Get all subscribers
    subscriber_ids = post.active_subscribers.pluck(:id)

    # Get all users who upvoted the post
    upvoter_ids = post.likes.joins(:voter).pluck(:user_id)

    # Combine and remove duplicates and the person who changed the status
    user_ids = (subscriber_ids + upvoter_ids).uniq - [ changed_by.id ]

    User.where(id: user_ids)
  end

  def url
    post = params[:post]
    return unless post

    Rails.application.routes.url_helpers.post_path(post)
  end

  def message
    post_title = params[:post]&.title || "A post"
    old_status_name = params[:old_status]&.name || "unknown"
    new_status_name = params[:new_status]&.name || "unknown"

    "#{post_title} status changed from #{old_status_name} to #{new_status_name}"
  end
end
