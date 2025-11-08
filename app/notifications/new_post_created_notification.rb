# frozen_string_literal: true

# Notification sent to admins when a new post is created
class NewPostCreatedNotification < Noticed::Event
  deliver_by :database

  # Params:
  # - post: The newly created post
  # - author: The user who created the post

  # Notify all admin users except the post author
  def notification_recipients
    post = params[:post]
    author = params[:author]

    return User.none unless post && author

    # Find all admin users except the author
    User.where(role: :administrator).where.not(id: author.id)
  end

  def url
    post = params[:post]
    return unless post

    Rails.application.routes.url_helpers.post_path(post)
  end

  def message
    author_name = params[:author]&.name || "Someone"
    post_title = params[:post]&.title || "a new post"

    "#{author_name} created #{post_title}"
  end
end
