# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user
  allow_unauthenticated_access only: %i[show]

  def show
    authorize @user
    # TODO: Refactor this to use better queries, pagination and maybe just break it into multiple controller actions
    @posts = @user.posts.includes(:likes, :category).order(created_at: :desc)
    @comments = @user.comments.includes(:likes, :post).order(created_at: :desc)
    @likes = @user.likes.includes(:likeable).order(created_at: :desc)
    
    # Pre-calculate stats for better performance
    @stats = {
      posts_count: @posts.size,
      total_votes: @posts.sum(&:likes_count),
      comments_count: @comments.size,
      helpful_votes: @comments.sum(&:likes_count)
    }
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
