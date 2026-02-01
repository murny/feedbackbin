# frozen_string_literal: true

# MentionNotifier determines who should be notified when a user is mentioned.
#
# Notification rules:
# - Notify the mentionee (the person who was mentioned)
# - Don't notify if it's a self-mention (user mentioned themselves)
#
# Note: Users never get notified for mentioning themselves
class Notifier::MentionNotifier < Notifier
  def initialize(source)
    @source = source
    @creator = source.mentioner
  end

  private

    def recipients
      return [] if source.self_mention?

      [ source.mentionee ]
    end
end
