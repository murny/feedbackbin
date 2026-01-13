# frozen_string_literal: true

# Event::Description generates human-readable descriptions of events.
# It provides different formats (HTML, plain text) and personalizes based on the viewer.
#
# Example usage:
#   event = Event.find(123)
#   description = event.description_for(current_user)
#   description.to_html         # => "<strong>You</strong> created <strong>Feature Request</strong>"
#   description.to_plain_text   # => "Shane created \"Feature Request\""
class Event::Description
  include ActionView::Helpers::TagHelper
  include ERB::Util

  attr_reader :event, :user

  def initialize(event, user)
    @event = event
    @user = user
  end

  def to_html
    to_sentence(creator_tag, idea_title_tag).html_safe
  end

  def to_plain_text
    to_sentence(creator_name, quoted(idea.title))
  end

  private

    def to_sentence(creator, idea_title)
      if event.action.comment_created?
        comment_sentence(creator, idea_title)
      else
        action_sentence(creator, idea_title)
      end
    end

    def creator_tag
      tag.strong data: { creator_id: event.creator.id } do
        tag.span(I18n.t("events.you"), data: { only_visible_to_you: true }) +
        tag.span(event.creator.name, data: { only_visible_to_others: true })
      end
    end

    def idea_title_tag
      tag.strong idea.title
    end

    def creator_name
      h(event.creator.name)
    end

    def quoted(text)
      %("#{h text}")
    end

    def idea
      @idea ||= event.action.comment_created? ? event.eventable.idea : event.eventable
    end

    def comment_sentence(creator, idea_title)
      "#{creator} #{I18n.t('events.actions.commented_on')} #{idea_title}"
    end

    def action_sentence(creator, idea_title)
      case event.action
      when "idea_created"
        "#{creator} #{I18n.t('events.actions.created')} #{idea_title}"
      when "idea_status_changed"
        status_changed_sentence(creator, idea_title)
      when "idea_board_changed"
        moved_sentence(creator, idea_title)
      when "idea_title_changed"
        renamed_sentence(creator, idea_title)
      end
    end

    def status_changed_sentence(creator, idea_title)
      %(#{creator} #{I18n.t('events.actions.changed_status')} #{idea_title} #{I18n.t('events.to')} "#{h event.new_status}")
    end

    def moved_sentence(creator, idea_title)
      %(#{creator} #{I18n.t('events.actions.moved')} #{idea_title} #{I18n.t('events.to')} "#{h event.new_board}")
    end

    def renamed_sentence(creator, idea_title)
      %(#{creator} #{I18n.t('events.actions.changed_title')} #{idea_title} (#{I18n.t('events.was')}: "#{h event.old_title}"))
    end
end
