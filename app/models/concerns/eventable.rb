# frozen_string_literal: true

# Eventable concern provides event tracking capabilities to models.
# Include this in models that should generate events (e.g., Idea, Comment).
#
# Example usage in Idea model:
#   include Eventable
#
#   def publish
#     track_event(:published)
#   end
module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable, dependent: :destroy
  end

  # Track an event for this model
  #
  # @param action [Symbol, String] The action name (e.g., :published, :status_changed)
  # @param creator [User] The user who triggered the event (defaults to Current.user)
  # @param board [Board] The board context (defaults to self.board)
  # @param particulars [Hash] Additional event-specific data
  #
  # Example:
  #   track_event(:status_changed, particulars: { old_status: "Open", new_status: "In Progress" })
  def track_event(action, creator: Current.user, board: self.board, **particulars)
    return unless should_track_event?

    board.events.create!(
      action: "#{eventable_prefix}_#{action}",
      creator: creator,
      board: board,
      eventable: self,
      particulars: particulars
    )
  end

  # Override in including class to respond to event creation
  # This is called after an event is created for this model
  #
  # Example:
  #   def event_was_created(event)
  #     # Create system comment, update timestamps, etc.
  #   end
  def event_was_created(event)
    # Default: do nothing
    # Subclasses can override this to respond to events
  end

  private

  # Override in including class to conditionally track events
  def should_track_event?
    true
  end

  # Get the prefix for event actions based on model name
  # e.g., Idea -> "idea", Comment -> "comment"
  def eventable_prefix
    self.class.name.demodulize.underscore
  end
end
