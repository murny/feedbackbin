# frozen_string_literal: true

# Notification represents a notification sent to a user about an event.
# Notifications are created automatically when events occur that should notify users.
#
# Example:
#   # When someone comments on an idea you're watching:
#   notification = Notification.create!(
#     user: watcher,
#     creator: commenter,
#     source: comment_created_event
#   )
class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :creator, class_name: "User"
  belongs_to :source, polymorphic: true  # Event (for now)

  # Delegate to source event for getting the actual subject (Idea or Comment)
  delegate :eventable, to: :source, prefix: :notifiable, allow_nil: true
  delegate :description_for, to: :source

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Broadcast notification count updates to user
  after_create_commit :broadcast_unread_count
  after_update_commit :broadcast_unread_count, if: :saved_change_to_read_at?

  # Mark notification as read
  def mark_as_read!
    update!(read_at: Time.current) unless read?
  end

  # Mark notification as unread
  def mark_as_unread!
    update!(read_at: nil) if read?
  end

  # Check if notification is read
  def read?
    read_at.present?
  end

  # Check if notification is unread
  def unread?
    !read?
  end

  # Get the URL for this notification's subject
  def url
    case notifiable_eventable
    when Idea
      Rails.application.routes.url_helpers.idea_path(notifiable_eventable)
    when Comment
      Rails.application.routes.url_helpers.idea_path(notifiable_eventable.idea, anchor: "comment_#{notifiable_eventable.id}")
    end
  end

  private

  def broadcast_unread_count
    broadcast_update_to(
      [user, :notifications],
      target: "unread_notifications_count",
      partial: "notifications/unread_count",
      locals: { count: user.notifications.unread.count }
    )
  end
end
