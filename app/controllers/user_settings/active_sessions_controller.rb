# frozen_string_literal: true

module UserSettings
  class ActiveSessionsController < ApplicationController
    skip_after_action :verify_authorized

    def index
      @sessions = Current.identity.sessions.order(created_at: :desc)
    end

    def destroy
      session = Current.identity.sessions.find(params[:id])
      session.destroy

      redirect_to user_settings_active_sessions_path, notice: t(".session_revoked")
    end
  end
end
