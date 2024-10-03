# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show]
  allow_unauthenticated_access only: %i[show]

  def show
  end

  private

  def set_user
    @user = User.find(params.expect(:id))
  end
end
