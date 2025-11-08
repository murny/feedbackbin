# frozen_string_literal: true

class NotificationsController < ApplicationController
  before_action :require_authentication
  before_action :set_notification, only: [ :update ]

  # GET /notifications
  def index
    @pagy, @notifications = pagy(Current.user.notifications, limit: 25)
  end

  # PATCH /notifications/:id/mark_as_read
  def update
    @notification.update(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: t(".success") }
      format.turbo_stream
    end
  end

  # POST /notifications/mark_all_as_read
  def mark_all_as_read
    Current.user.unread_notifications.update_all(read_at: Time.current)

    respond_to do |format|
      format.html { redirect_to notifications_path, notice: t(".success") }
      format.turbo_stream
    end
  end

  private

    def set_notification
      @notification = Current.user.notifications.find(params[:id])
    end
end
