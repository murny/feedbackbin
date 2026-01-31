# frozen_string_literal: true

# Mention::Description generates human-readable descriptions of mentions.
# It provides different formats (HTML, plain text) and personalizes based on the viewer.
#
# Example usage:
#   mention = Mention.find(123)
#   description = Mention::Description.new(mention, current_user)
#   description.to_html         # => "<strong>Shane</strong> mentioned you in <strong>Feature Request</strong>"
#   description.to_plain_text   # => "Shane mentioned you in \"Feature Request\""
class Mention::Description
  include ActionView::Helpers::TagHelper
  include ERB::Util

  attr_reader :mention, :user

  def initialize(mention, user)
    @mention = mention
    @user = user
  end

  def to_html
    "#{creator_tag} #{I18n.t('mentions.actions.mentioned_you_in')} #{idea_title_tag}".html_safe
  end

  def to_plain_text
    "#{creator_name} #{I18n.t('mentions.actions.mentioned_you_in')} #{quoted(idea.title)}"
  end

  private

    def creator_tag
      tag.strong data: { creator_id: mention.mentioner.id } do
        tag.span(I18n.t("events.you"), data: { only_visible_to_you: true }) +
        tag.span(mention.mentioner.name, data: { only_visible_to_others: true })
      end
    end

    def idea_title_tag
      tag.strong idea.title
    end

    def creator_name
      h(mention.mentioner.name)
    end

    def quoted(text)
      %("#{h text}")
    end

    def idea
      mention.idea
    end
end
