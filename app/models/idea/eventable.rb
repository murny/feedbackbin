# frozen_string_literal: true

module Idea::Eventable
  extend ActiveSupport::Concern

  include ::Eventable

  included do
    after_create_commit :track_creation
    after_update :track_status_change, if: :saved_change_to_status_id?
    after_update :track_board_change, if: :saved_change_to_board_id?
    after_update :track_title_change, if: :saved_change_to_title?
  end

  # Called by Event after creation (via Eventable concern)
  # Creates system comments for visible audit trail
  def event_was_created(event)
    Idea::SystemCommenter.new(self, event).comment
  end

  private

    def track_creation
      track_event(:created)
    end

    def track_status_change
      old_status = Status.find_by(id: status_id_before_last_save)&.name || I18n.t("ideas.default_status")
      track_event(:status_changed, old_status: old_status, new_status: status_name)
    end

    def track_board_change
      old_board = Board.find_by(id: board_id_before_last_save)&.name || I18n.t("events.unknown_item")
      track_event(:board_changed, old_board: old_board, new_board: board.name)
    end

    def track_title_change
      track_event(:title_changed, old_title: title_before_last_save, new_title: title)
    end
end
