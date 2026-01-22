# frozen_string_literal: true

class TaggingsController < ApplicationController
  skip_after_action :verify_authorized

  before_action :set_idea

  def create
    @tag = Current.account.tags.find_or_create_by(title: tagging_params[:title])

    unless @idea.tags.include?(@tag)
      @idea.tags << @tag
      flash.now[:notice] = t(".successfully_tagged")
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @idea }
    end
  end

  def destroy
    @tagging = Tagging.find(params[:id])
    @tag = @tagging.tag
    @tagging.destroy!

    respond_to do |format|
      flash.now[:notice] = t(".successfully_untagged")
      format.turbo_stream
      format.html { redirect_to @idea, status: :see_other }
    end
  end

  private

    def set_idea
      @idea = Idea.find(params[:idea_id])
    end

    def tagging_params
      params.expect(tagging: [ :title ])
    end
end
