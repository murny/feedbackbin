# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user
  allow_unauthenticated_access only: %i[show]

  def show
    authorize @user
    # TODO: Refactor this to use better queries, pagination and maybe just break it into multiple controller actions
    @posts = @user.posts.order(created_at: :desc)
    @comments = @user.comments.order(created_at: :desc)
    @likes = @user.likes.order(created_at: :desc)
  end

  def destroy
    authorize @user
    @user.destroy
    redirect_to root_path, notice: t(".account_deleted")
  end

  private

    def set_user
      @user = User.find(params.expect(:id))
    end
end
