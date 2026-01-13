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
  include ActionView::Helpers::TagHelper
  include ERB::Util

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
    to_sentence(creator_name, quoted(idea_title))
  end

  private

    delegate :creator, :eventable, :action, to: :event

    # Build a sentence from creator and subject
    def to_sentence(creator_part, subject_part)
      case action.to_s
      when "idea_created"
        "#{creator_part} #{I18n.t('events.actions.created')} #{subject_part}"
      when "idea_status_changed"
        status_changed_sentence(creator_part, subject_part)
      when "idea_board_changed"
        board_changed_sentence(creator_part, subject_part)
      when "idea_title_changed"
        title_changed_sentence(creator_part, subject_part)
      when "comment_created"
        "#{creator_part} #{I18n.t('events.actions.commented_on')} #{subject_part}"
      else
        "#{creator_part} #{h action.to_s.split('_').last} #{subject_part}"
      end
    end

    def status_changed_sentence(creator_part, subject_part)
      new_status = event.respond_to?(:new_status) ? event.new_status : eventable.try(:status_name)
      "#{creator_part} #{I18n.t('events.actions.changed_status')} #{subject_part} #{I18n.t('events.to')} #{tag.strong h(new_status)}"
    end

    def board_changed_sentence(creator_part, subject_part)
      new_board = event.respond_to?(:new_board) ? event.new_board : eventable.try(:board)&.name
      "#{creator_part} #{I18n.t('events.actions.moved')} #{subject_part} #{I18n.t('events.to')} #{tag.strong h(new_board)}"
    end

    def title_changed_sentence(creator_part, subject_part)
      old_title = event.respond_to?(:old_title) ? event.old_title : nil
      new_title = event.respond_to?(:new_title) ? event.new_title : nil
      %(#{creator_part} #{I18n.t('events.actions.changed_title')} #{I18n.t('events.from')} "#{h old_title}" #{I18n.t('events.to')} "#{h new_title}")
    end

    # Creator name (always use actual name in plain text for notifications/webhooks)
    def creator_name
      h(creator.name)
    end

    # HTML tag for creator (uses tag helper for auto-escaping)
    def creator_tag
      tag.strong data: { creator_id: creator.id } do
        tag.span(I18n.t("events.you"), data: { only_visible_to_you: true }) +
        tag.span(creator.name, data: { only_visible_to_others: true })
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

    # HTML tag for idea title (uses tag helper for auto-escaping)
    def idea_title_tag
      tag.strong idea_title
    end

    def quoted(text)
      %("#{h text}")
    end
end
