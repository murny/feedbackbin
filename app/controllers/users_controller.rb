# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user
  allow_unauthenticated_access only: %i[show]

  def show
    authorize @user
    # TODO: Refactor this to use better queries, pagination and maybe just break it into multiple controller actions
    @ideas = @user.ideas.includes(:votes, :board).order(created_at: :desc)
    @comments = @user.comments.includes(:votes, :idea).order(created_at: :desc)
    @votes = @user.votes.includes(:voteable).order(created_at: :desc)

    # Pre-calculate stats for better performance
    @stats = {
      ideas_count: @ideas.size,
      total_votes: @ideas.sum(&:votes_count),
      comments_count: @comments.size,
      helpful_votes: @comments.sum(&:votes_count)
    }
  end

  def destroy
    authorize @user
    @user.destroy
    redirect_to root_path, notice: t(".user_deleted")
  end

  private

    def set_user
      @user = User.find(params.expect(:id))
    end
end
