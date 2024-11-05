# frozen_string_literal: true

class FirstRunsController < ApplicationController
  allow_unauthenticated_access
  skip_after_action :verify_authorized

  before_action :prevent_repeats

  def show
    @user = User.new
  end

  def create
    account = FirstRun.create!(user_params)
    start_new_session_for account.owner

    redirect_to root_path, notice: t(".account_created")
  end

  private

  def prevent_repeats
    redirect_to root_path if Account.any?
  end

  def user_params
    params.require(:user).permit(:username, :name, :avatar, :email_address, :password)
  end
end
