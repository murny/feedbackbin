# frozen_string_literal: true

class VotesController < ApplicationController
  VOTEABLE_APPROVELIST = [ "Idea", "Comment" ].freeze

  skip_after_action :verify_authorized

  before_action :set_voteable

  def update
    respond_to do |format|
      if @voteable.voted_by?(Current.user)
        @voteable.unvote(Current.user)
        flash.now[:notice] = t(".successfully_unvoted", resource: @voteable.class.name)
      else
        @voteable.vote(Current.user)
        flash.now[:notice] = t(".successfully_voted", resource: @voteable.class.name)
      end
      format.html { redirect_to @voteable }
      format.turbo_stream
    end
  end

  private

    def set_voteable
      unless VOTEABLE_APPROVELIST.include?(params[:voteable_type])
        return head :unprocessable_entity
      end

      @voteable = params[:voteable_type].safe_constantize.find(params[:voteable_id])
    end
end
