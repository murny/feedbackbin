# frozen_string_literal: true

module Ideas
  class PinsController < ApplicationController
    include IdeaScoped
    skip_after_action :verify_authorized
    before_action :ensure_admin

    # POST /ideas/:idea_id/pin
    def create
      @idea.update!(pinned: true)

      respond_to do |format|
        format.html { redirect_to @idea, notice: t(".pinned") }
        format.turbo_stream
      end
    end

    # DELETE /ideas/:idea_id/pin
    def destroy
      @idea.update!(pinned: false)

      respond_to do |format|
        format.html { redirect_to @idea, notice: t(".unpinned") }
        format.turbo_stream
      end
    end
  end
end
