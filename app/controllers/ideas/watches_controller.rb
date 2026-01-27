# frozen_string_literal: true

module Ideas
  class WatchesController < ApplicationController
    include IdeaScoped


    def show
      fresh_when etag: @idea.watch_for(Current.user) || "none"
    end

    def create
      @idea.watch_by(Current.user)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @idea }
      end
    end

    def destroy
      @idea.unwatch_by(Current.user)

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @idea }
      end
    end
  end
end
