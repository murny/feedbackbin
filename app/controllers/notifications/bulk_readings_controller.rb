# frozen_string_literal: true

class Notifications::BulkReadingsController < ApplicationController
  skip_after_action :verify_authorized

  def create
    Current.user.notifications.unread.read_all

    respond_to do |format|
      format.html { redirect_to notifications_path }
      format.turbo_stream
      format.json { head :no_content }
    end
  end
end
