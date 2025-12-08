# frozen_string_literal: true

module Eventable
  extend ActiveSupport::Concern

  included do
    has_many :events, as: :eventable, dependent: :destroy
  end

  # Track an event for this record
  #
  # @param action [Symbol, String] The action being tracked (e.g., :created, :updated, :published)
  # @param creator [User] The user who performed the action (defaults to Current.user)
  # @param particulars [Hash] Additional context specific to this event
  #
  # Example:
  #   post.track_event(:published, particulars: { notify_subscribers: true })
  #   comment.track_event(:edited, creator: Current.user, particulars: { previous_body: "..." })
  #
  def track_event(action, creator: Current.user, particulars: {})
    return unless should_track_event?

    events.create!(
      action: "#{eventable_prefix}_#{action}",
      creator: creator || Current.organization&.system_user,
      particulars: particulars
      # organization defaults to Current.organization via Event model
    )
  end

  private

    # Override in models if event tracking should be conditional
    def should_track_event?
      true
    end

    # Override in models to customize the event action prefix
    # Default: underscored model name (e.g., "post", "comment")
    def eventable_prefix
      self.class.name.underscore
    end
end
