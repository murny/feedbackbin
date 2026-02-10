# frozen_string_literal: true

# Idea::Eventable::SystemCommenter creates system comments for idea events.
# These comments appear in the comment thread to provide a visible audit trail.
#
# Example:
#   SystemCommenter.new(idea, event).comment
#   # Creates: "Alice changed the status from Open to In Progress"
class Idea::Eventable::SystemCommenter
  include ERB::Util

  attr_reader :idea, :event

  def initialize(idea, event)
    @idea = idea
    @event = event
  end

  # Create a system comment if applicable
  def comment
    return unless comment_body.present?

    idea.comments.create!(
      creator: idea.account.system_user,
      body: comment_body,
      created_at: event.created_at
    )
  end

  private

    # Generate comment body based on event action
    def comment_body
      case event.action.to_s
      when "idea_created"
        nil # Don't create system comment for creation (the idea itself is the record)
      when "idea_status_changed"
        %(#{creator_name} <strong>changed the status</strong> from "#{old_status}" to "#{new_status}")
      when "idea_board_changed"
        %(#{creator_name} <strong>moved</strong> this from "#{old_board}" to "#{new_board}")
      when "idea_title_changed"
        %(#{creator_name} <strong>changed the title</strong> from "#{old_title}" to "#{new_title}")
      end
    end

    # HTML-escape the creator's name
    def creator_name
      h event.creator.name
    end

    # Get old status from event particulars
    def old_status
      h event.particulars["old_status"]
    end

    # Get new status from event particulars
    def new_status
      h event.particulars["new_status"]
    end

    # Get old board from event particulars
    def old_board
      h event.particulars["old_board"]
    end

    # Get new board from event particulars
    def new_board
      h event.particulars["new_board"]
    end

    # Get old title from event particulars
    def old_title
      h event.particulars["old_title"]
    end

    # Get new title from event particulars
    def new_title
      h event.particulars["new_title"]
    end
end
