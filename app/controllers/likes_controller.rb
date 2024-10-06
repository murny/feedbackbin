# frozen_string_literal: true

class LikesController < ApplicationController
  CLASS_APPROVELIST = ["Post", "Comment"].freeze

  include ActionView::RecordIdentifier

  before_action :set_likeable

  def update
    if @likeable.liked_by?(Current.user)
      @likeable.unlike(Current.user)
    else
      @likeable.like(Current.user)
    end

    render partial: "likes", locals: {likeable: @likeable}
  end

  private

  def set_likeable
    return unless CLASS_APPROVELIST.include?(params[:likeable_type])
    @likeable = params[:likeable_type].safe_constantize.find(params[:likeable_id])
  end
end
