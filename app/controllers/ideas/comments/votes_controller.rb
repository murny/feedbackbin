# frozen_string_literal: true

class Ideas::Comments::VotesController < ApplicationController
  include IdeaScoped

  before_action :set_comment
  before_action :set_voteable

  def update
    respond_to do |format|
      if @voteable.voted_by?(Current.user)
        @voteable.unvote(Current.user)
        flash.now[:notice] = t(".successfully_unvoted")
      else
        @voteable.vote(Current.user)
        flash.now[:notice] = t(".successfully_voted")
      end
      format.html { redirect_to idea_comment_path(@idea, @comment) }
      format.turbo_stream { render "votes/update" }
    end
  end

  private

    def set_comment
      @comment = @idea.comments.find(params[:comment_id])
    end

    def set_voteable
      @voteable = @comment
    end
end
