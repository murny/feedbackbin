# frozen_string_literal: true

# IdeaEventNotifier determines who should be notified for Idea-related events.
#
# Notification rules:
# - idea_created: Board creator (if they didn't make the change)
# - idea_status_changed: Idea watchers AND voters (deduped, excluding the person who made the change)
# - idea_board_changed: Idea watchers (excluding the person who made the change)
# - idea_title_changed: Idea watchers (excluding the person who made the change)
#
# Note: Users never get notified for their own actions
class Notifier::IdeaEventNotifier < Notifier
  delegate :creator, to: :source

  def notify
    super.tap do |notifications|
      return notifications unless source.action.to_s == "idea_status_changed"

      notifications.each do |notification|
        IdeaStatusChangeMailer
          .with(event: source, recipient: notification.user)
          .status_changed
          .deliver_later
      end
    end
  end

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
      when "idea_status_changed"
        union_voters_and_watchers
      when "idea_board_changed", "idea_title_changed"
        # Notify all idea watchers except the person who made the change
        idea.watchers.where.not(id: creator.id).to_a
      else
        []
      end
    end

    def union_voters_and_watchers
      watcher_ids = idea.watchers.where.not(id: creator.id).pluck(:id)
      voter_ids   = idea.voters.active.where.not(role: [ :system, :bot ]).where.not(id: creator.id).pluck(:id)
      ids = (watcher_ids | voter_ids)
      User.where(id: ids).to_a
    end
end
