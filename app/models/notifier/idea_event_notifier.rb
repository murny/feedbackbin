# frozen_string_literal: true

# IdeaEventNotifier determines who should be notified for Idea-related events.
#
# Notification rules:
# - idea_created: Board members (future: watchers)
# - idea_status_changed: Idea creator (if they didn't make the change)
# - idea_board_changed: Idea creator (if they didn't make the change)
# - idea_title_changed: Idea creator (if they didn't make the change)
#
# Note: Users never get notified for their own actions
class Notifier::IdeaEventNotifier < Notifier
  private

  delegate :idea, to: :source, prefix: false
  alias_method :idea, :eventable

  def eventable
    source.eventable
  end

  # Determine recipients based on the event action
  def recipients
    case source.action.to_s
    when "idea_created"
      # Future: notify board watchers
      # For now, notify board creator if different from idea creator
      [ idea.board.creator ].compact.reject { |u| u == creator }
    when "idea_status_changed", "idea_board_changed", "idea_title_changed"
      # Notify the idea creator if they weren't the one who made the change
      idea.creator == creator ? [] : [ idea.creator ]
    else
      []
    end
  end

  # Don't notify if creator is the same as the event creator
  def should_notify?
    creator.present?
  end
end
