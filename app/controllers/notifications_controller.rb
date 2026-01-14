# frozen_string_literal: true

# NotificationsController handles user notifications.
class NotificationsController < ApplicationController
  skip_after_action :verify_authorized

  MAX_UNREAD_NOTIFICATIONS = 500

  def index
    @unread = Current.user.notifications.unread.ordered.preloaded.limit(MAX_UNREAD_NOTIFICATIONS)
    @read = Current.user.notifications.where.not(read_at: nil).ordered.preloaded.limit(50)

    respond_to do |format|
      format.html
      format.json
    end
  end
end
