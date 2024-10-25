# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show]
  allow_unauthenticated_access only: %i[show]

  def show
    # TODO: Refactor this to use better queries, pagination and maybe just break it into multiple controller actions
    @posts = @user.posts.order(created_at: :desc)
    @comments = @user.comments.order(created_at: :desc)
    @likes = @user.likes.order(created_at: :desc)
  end

  private

  def set_user
    @user = User.find(params.expect(:id))
  end
end
