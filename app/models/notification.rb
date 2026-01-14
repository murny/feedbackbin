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
  belongs_to :account, default: -> { user.account }
  belongs_to :user
  belongs_to :creator, class_name: "User"
  belongs_to :source, polymorphic: true  # Event (for now)

  # Delegate to source event for getting the actual subject (Idea or Comment)
  delegate :eventable, to: :source, prefix: :notifiable, allow_nil: true
  delegate :description_for, to: :source

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :ordered, -> { order(read_at: :desc, created_at: :desc) }
  scope :preloaded, -> { preload(:creator, :account, source: [ :board, :creator, { eventable: [ :board ] } ]) }

  # Broadcast notification to user's notification list
  after_create_commit :broadcast_unread
  after_destroy_commit :broadcast_read

  # Mark all notifications as read
  def self.read_all
    all.each { |notification| notification.read }
  end

  # Mark notification as read
  def read
    update!(read_at: Time.current)
    broadcast_read
  end

  # Mark notification as unread
  def unread
    update!(read_at: nil)
    broadcast_unread
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

    def broadcast_unread
      broadcast_prepend_later_to user, :notifications, target: "notifications"
    end

    def broadcast_read
      broadcast_remove_to user, :notifications
    end
end
