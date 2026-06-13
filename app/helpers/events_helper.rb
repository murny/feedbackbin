# frozen_string_literal: true

module EventsHelper
  def activity_timeline_icon_for(event)
    case event.action.to_s
    when "idea_status_changed" then "circle-dot"
    when "idea_board_changed" then "move"
    when "idea_title_changed" then "pencil"
    when "idea_mentioned_in_changelog" then "megaphone"
    else "activity"
    end
  end
end
