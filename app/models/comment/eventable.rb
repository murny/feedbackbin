# frozen_string_literal: true

module Comment::Eventable
  extend ActiveSupport::Concern

  include ::Eventable

  included do
    after_create_commit :track_creation
  end

  def event_was_created(event)
    # Future: could update activity timestamps, create notifications, etc.
    # idea.touch_last_active_at
  end

  private

    def should_track_event?
      !creator.system?
    end

    def track_creation
      idea.watch_by(creator) if should_track_event?
      track_event(:created, board: idea.board, creator: creator)
    end
end
