# frozen_string_literal: true

class Users::Settings::SessionsController < ApplicationController
  def index
    @sessions = Current.user.sessions.order(created_at: :desc)
  end

  def destroy
    session = Current.user.sessions.find(params[:id])
    session.destroy

    redirect_to users_settings_sessions_path, notice: t(".session_revoked")
  end
end
