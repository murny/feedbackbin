# frozen_string_literal: true

class Users::Settings::NotificationsController < ApplicationController
  before_action :set_user

  def show
  end

  private

  def set_user
    @user = Current.user
  end
end
