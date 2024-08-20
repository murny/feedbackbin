# frozen_string_literal: true

class Users::Settings::SessionsController < ApplicationController
  def index
    @sessions = Current.user.sessions.order(created_at: :desc)
  end
end
