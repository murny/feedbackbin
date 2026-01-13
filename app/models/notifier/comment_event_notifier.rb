# frozen_string_literal: true

# CommentEventNotifier determines who should be notified for Comment-related events.
#
# Notification rules:
# - comment_created: Notify all idea watchers (excluding the commenter)
#
# Note: Users never get notified for their own actions
class Notifier::CommentEventNotifier < Notifier
  delegate :creator, to: :source

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
      # Notify all idea watchers except the person who made the comment
      idea.watchers.where.not(id: creator.id).to_a
    else
      []
    end
  end
end
