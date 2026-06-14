# frozen_string_literal: true

class Ideas::Comments::VotesController < ApplicationController
  include IdeaScoped

  before_action :set_comment
  before_action :set_voteable

  def update
    if @voteable.voted_by?(Current.user)
      @voteable.unvote(Current.user)
      flash.now[:notice] = t(".successfully_unvoted")
    else
      @voteable.vote(Current.user)
      flash.now[:notice] = t(".successfully_voted")
    end

    respond_to do |format|
      format.html { redirect_to idea_comment_path(@idea, @comment) }
      format.turbo_stream { render "votes/update" }
    end
  rescue ActiveRecord::RecordInvalid
    respond_to do |format|
      format.html do
        flash[:alert] = t(".error")
        redirect_to idea_comment_path(@idea, @comment)
      end
      format.turbo_stream do
        flash.now[:alert] = t(".error")
        render "votes/update", status: :unprocessable_entity
      end
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
