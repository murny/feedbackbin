# frozen_string_literal: true

class UsersController < ApplicationController
  allow_unauthenticated_access only: %i[show]
  skip_after_action :verify_authorized

  before_action :set_user
  before_action :ensure_permission_to_change_user, only: :destroy

  def show
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
    @user.destroy
    redirect_to root_path, notice: t(".user_deleted")
  end

  private

    def set_user
      @user = User.find(params.expect(:id))
    end

    def ensure_permission_to_change_user
      head :forbidden unless Current.user.can_change?(@user)
    end
end
