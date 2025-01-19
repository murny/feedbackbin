# frozen_string_literal: true

class LikesController < ApplicationController
  LIKEABLE_APPROVELIST = [ "Post", "Comment" ].freeze

  skip_after_action :verify_authorized

  before_action :set_likeable

  def update
    respond_to do |format|
      if @likeable.liked_by?(Current.user)
        @likeable.unlike(Current.user)
        flash.now[:notice] = t(".successfully_unliked", resource: @likeable.class.name)
      else
        @likeable.like(Current.user)
        flash.now[:notice] = t(".successfully_liked", resource: @likeable.class.name)
      end
      format.html { redirect_to @likeable }
      format.turbo_stream
    end
  end

  private

    def set_likeable
      unless LIKEABLE_APPROVELIST.include?(params[:likeable_type])
        return head :unprocessable_entity
      end

      @likeable = params[:likeable_type].safe_constantize.find(params[:likeable_id])
    end
end
