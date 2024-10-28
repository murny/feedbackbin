# frozen_string_literal: true

module UserSettings
  class ActiveSessionsController < ApplicationController
    def index
      @sessions = Current.user.sessions.order(created_at: :desc)
    end

    def destroy
      session = Current.user.sessions.find(params[:id])
      session.destroy

      redirect_to user_settings_active_sessions_path, notice: t(".session_revoked")
    end
  end
end
