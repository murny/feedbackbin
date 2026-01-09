# frozen_string_literal: true

# NotificationsController handles user notifications.
# Users can view their notifications and mark them as read/unread.
class NotificationsController < ApplicationController
  before_action :set_notification, only: [ :update, :destroy ]

  # GET /notifications
  def index
    @notifications = Current.user.notifications
      .includes(:creator, source: :eventable)
      .recent
      .limit(50)

    @unread_count = Current.user.notifications.unread.count
  end

  # PATCH /notifications/:id
  def update
    if params[:read] == "true"
      @notification.mark_as_read!
      respond_to do |format|
        format.html { redirect_to notifications_path, notice: t(".marked_as_read") }
        format.turbo_stream
      end
    else
      @notification.mark_as_unread!
      respond_to do |format|
        format.html { redirect_to notifications_path, notice: t(".marked_as_unread") }
        format.turbo_stream
      end
    end
  end

  # POST /notifications/mark_all_read
  def mark_all_read
    Current.user.notifications.unread.update_all(read_at: Time.current)
    redirect_to notifications_path, notice: t(".all_marked_as_read")
  end

  private

  def set_notification
    @notification = Current.user.notifications.find(params[:id])
  end
end
