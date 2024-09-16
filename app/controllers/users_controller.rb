# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show]
  allow_unauthenticated_access

  def show
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
end
