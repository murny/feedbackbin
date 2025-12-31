# frozen_string_literal: true

# CommentEventNotifier determines who should be notified for Comment-related events.
#
# Notification rules:
# - comment_created: Notify:
#   1. The idea creator (if they didn't write the comment)
#   2. Other users who have commented on this idea (excluding current commenter)
#
# Note: Users never get notified for their own actions
class Notifier::CommentEventNotifier < Notifier
  private

  delegate :comment, to: :source, prefix: false
  alias_method :comment, :eventable

  def eventable
    source.eventable
  end

  def idea
    comment.idea
  end

  # Determine recipients for comment events
  def recipients
    case source.action.to_s
    when "comment_created"
      # Collect all potential recipients
      potential_recipients = []

      # 1. Notify idea creator if they didn't write the comment
      potential_recipients << idea.creator unless idea.creator == creator

      # 2. Notify other commenters on this idea (except current commenter)
      other_commenters = idea.comments
        .where.not(creator_id: creator.id)
        .includes(:creator)
        .map(&:creator)
        .uniq

      potential_recipients.concat(other_commenters)

      # Return unique recipients, excluding the comment creator
      potential_recipients.uniq.reject { |u| u == creator }
    else
      []
    end
  end

  # Don't notify if there's no creator
  def should_notify?
    creator.present?
  end
end
