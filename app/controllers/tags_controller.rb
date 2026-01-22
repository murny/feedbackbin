# frozen_string_literal: true

class TagsController < ApplicationController
  skip_after_action :verify_authorized

  def index
    @tags = Current.account.tags.alphabetically
    respond_to do |format|
      format.json { render json: @tags }
      format.turbo_stream
    end
  end

  def create
    @tag = Current.account.tags.find_or_create_by(title: tag_params[:title])
    respond_to do |format|
      format.turbo_stream
      format.json { render json: @tag, status: :created }
    end
  end

  private

    def tag_params
      params.expect(tag: [ :title ])
    end
end
