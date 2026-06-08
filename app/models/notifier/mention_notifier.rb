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
      return [] if internal_comment_to_non_staff?

      [ source.mentionee ]
    end

    def internal_comment_to_non_staff?
      return false unless source.source.is_a?(Comment) && source.source.internal?

      !source.mentionee.admin?
    end
end
