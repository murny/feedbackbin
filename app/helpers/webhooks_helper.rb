# frozen_string_literal: true

module WebhooksHelper
  ACTION_LABELS = {
    idea_created: "Idea created",
    idea_status_changed: "Idea status changed",
    idea_board_changed: "Idea moved to another board",
    idea_title_changed: "Idea title changed",
    comment_created: "Comment added"
  }.with_indifferent_access.freeze

  def webhook_action_options(actions = Webhook::PERMITTED_ACTIONS)
    ACTION_LABELS.select { |key, _| actions.include?(key.to_s) }
  end

  def webhook_action_label(action)
    ACTION_LABELS[action] || action.to_s.humanize
  end
end
