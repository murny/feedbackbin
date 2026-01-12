# frozen_string_literal: true

# Event::Description generates human-readable descriptions of events.
# It provides different formats (HTML, plain text) and personalizes based on the viewer.
#
# Example usage:
#   event = Event.find(123)
#   description = event.description_for(current_user)
#   description.to_html         # => "You published <strong>Feature Request</strong>"
#   description.to_plain_text   # => "You published Feature Request"
class Event::Description
  attr_reader :event, :viewer

  def initialize(event, viewer)
    @event = event
    @viewer = viewer
  end

  # Generate HTML description for display
  def to_html
    to_sentence(creator_tag, idea_title_tag).html_safe
  end

  # Generate plain text description for notifications, webhooks, etc.
  def to_plain_text
    to_sentence(creator_name, idea_title)
  end

  private

    delegate :creator, :eventable, :action, to: :event

    # Build a sentence from creator and subject
    def to_sentence(creator_part, subject_part)
      case action.to_s
      when "idea_created"
        "#{creator_part} #{I18n.t('events.actions.created')} #{subject_part}"
      when "idea_status_changed"
        "#{creator_part} #{I18n.t('events.actions.changed_status')} #{subject_part} #{I18n.t('events.to')} #{status_tag}"
      when "idea_board_changed"
        "#{creator_part} #{I18n.t('events.actions.moved')} #{subject_part} #{I18n.t('events.to')} #{board_tag}"
      when "idea_title_changed"
        "#{creator_part} #{I18n.t('events.actions.changed_title')} #{I18n.t('events.from')} \"#{event.old_title}\" #{I18n.t('events.to')} \"#{event.new_title}\""
      when "comment_created"
        "#{creator_part} #{I18n.t('events.actions.commented_on')} #{subject_part}"
      else
        "#{creator_part} #{action.to_s.split('_').last} #{subject_part}"
      end
    end

    # Creator name or "You" for the viewer
    def creator_name
      creator == viewer ? I18n.t("events.you") : creator.name
    end

    # HTML tag for creator (linked or "You")
    def creator_tag
      if creator == viewer
        "<strong>#{I18n.t('events.you')}</strong>"
      else
        "<strong>#{creator.name}</strong>"
      end
    end

    # Get the idea title (works for both Idea and Comment events)
    def idea_title
      case eventable
      when Idea
        eventable.title
      when Comment
        eventable.idea.title
      else
        I18n.t("events.unknown_item")
      end
    end

    # HTML tag for idea title
    def idea_title_tag
      "<strong>#{idea_title}</strong>"
    end

    # Status name from particulars or current status
    def status_tag
      if event.respond_to?(:new_status)
        "<strong>#{event.new_status}</strong>"
      elsif eventable.respond_to?(:status)
        "<strong>#{eventable.status_name}</strong>"
      else
        ""
      end
    end

    # Board name from particulars or current board
    def board_tag
      if event.respond_to?(:new_board)
        "<strong>#{event.new_board}</strong>"
      elsif eventable.respond_to?(:board)
        "<strong>#{eventable.board.name}</strong>"
      else
        ""
      end
    end
end
