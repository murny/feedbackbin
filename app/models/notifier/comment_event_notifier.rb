# frozen_string_literal: true

# CommentEventNotifier determines who should be notified for Comment-related events.
#
# Notification rules:
# - comment_created: Notify all idea watchers (excluding the commenter)
#
# Note: Users never get notified for their own actions
class Notifier::CommentEventNotifier < Notifier
  delegate :creator, to: :source

  def notify
    super.tap do |notifications|
      return notifications unless source.action.to_s == "comment_created"

      notifications.each do |notification|
        IdeaCommentMailer
          .with(comment: comment, recipient: notification.user)
          .new_comment
          .deliver_later
      end
    end
  end

  private

    def comment
      source.eventable
    end

    def idea
      comment.idea
    end

    # Determine recipients for comment events
    def recipients
      case source.action.to_s
      when "comment_created"
        watchers = idea.watchers.where.not(id: creator.id)
        watchers = watchers.where(role: [ :owner, :admin ]) if comment.internal?
        watchers.to_a
      else
        []
      end
    end
end
