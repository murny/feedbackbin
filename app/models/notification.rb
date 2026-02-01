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
  belongs_to :source, polymorphic: true  # Event or Mention

  # Delegate to source event for getting the actual subject (Idea or Comment)
  delegate :eventable, to: :source, prefix: :notifiable, allow_nil: true

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

  # Get the description for this notification
  def description_for(user)
    case source
    when Event
      source.description_for(user)
    when Mention
      Mention::Description.new(source, user)
    end
  end

  # Get the URL for this notification's subject
  def url
    case source
    when Event
      event_url
    when Mention
      mention_url
    end
  end

  private

    def event_url
      case notifiable_eventable
      when Idea
        Rails.application.routes.url_helpers.idea_path(notifiable_eventable)
      when Comment
        Rails.application.routes.url_helpers.idea_path(notifiable_eventable.idea, anchor: "comment_#{notifiable_eventable.id}")
      end
    end

    def mention_url
      case source.source
      when Idea
        Rails.application.routes.url_helpers.idea_path(source.source)
      when Comment
        Rails.application.routes.url_helpers.idea_path(source.source.idea, anchor: "comment_#{source.source.id}")
      end
    end

    def broadcast_unread
      broadcast_prepend_later_to user, :notifications, target: "notifications"
    end

    def broadcast_read
      broadcast_remove_to user, :notifications
    end
end
