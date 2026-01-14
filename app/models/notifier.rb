# frozen_string_literal: true

# Notifier is a factory class that creates the appropriate notifier for a given source.
# It uses a naming convention to find the right notifier class based on the source type.
#
# For Event sources, it looks at the eventable type:
#   - Event with Idea eventable -> Notifier::IdeaEventNotifier
#   - Event with Comment eventable -> Notifier::CommentEventNotifier
#
# Example usage:
#   event = Event.find(123)
#   Notifier.for(event).notify  # Creates Notification records for recipients
class Notifier
  attr_reader :source, :creator

  # Factory method to create the appropriate notifier
  # @param source [Event] The source object that should trigger notifications
  # @return [Notifier subclass, nil] The appropriate notifier or nil if not found
  def self.for(source)
    case source
    when Event
      notifier_class_name = "Notifier::#{source.eventable.class.name}EventNotifier"
      notifier_class_name.safe_constantize&.new(source)
    else
      nil
    end
  end

  def initialize(source)
    @source = source
    @creator = source.creator
  end

  # Create notifications for all recipients
  # @return [Array<Notification>] Created notification records
  def notify
    return [] unless should_notify?

    # Processing recipients in order avoids deadlocks if notifications overlap
    recipients.uniq.sort_by(&:id).map do |recipient|
      Notification.create!(
        user: recipient,
        source: source,
        creator: creator
      )
    end
  end

  protected

    # Override in subclasses to determine who should be notified
    # @return [Array<User>] Users who should receive notifications
    def recipients
      []
    end

    # Don't notify if creator is a system user
    # @return [Boolean] Whether notifications should be sent
    def should_notify?
      !creator.system?
    end
end
