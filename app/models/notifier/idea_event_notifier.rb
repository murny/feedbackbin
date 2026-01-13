# frozen_string_literal: true

# IdeaEventNotifier determines who should be notified for Idea-related events.
#
# Notification rules:
# - idea_created: Board creator (if they didn't make the change)
# - idea_status_changed: Idea watchers (excluding the person who made the change)
# - idea_board_changed: Idea watchers (excluding the person who made the change)
# - idea_title_changed: Idea watchers (excluding the person who made the change)
#
# Note: Users never get notified for their own actions
class Notifier::IdeaEventNotifier < Notifier
  delegate :creator, to: :source

  private

  def idea
    source.eventable
  end

  # Determine recipients based on the event action
  def recipients
    case source.action.to_s
    when "idea_created"
      # Notify board creator if different from idea creator
      [ idea.board.creator ].compact - [ creator ]
    when "idea_status_changed", "idea_board_changed", "idea_title_changed"
      # Notify all idea watchers except the person who made the change
      idea.watchers.where.not(id: creator.id).to_a
    else
      []
    end
  end
end
