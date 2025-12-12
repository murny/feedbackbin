# frozen_string_literal: true

module Ideas
  class PinsController < ApplicationController
    before_action :set_idea

    # POST /ideas/:idea_id/pin
    def create
      authorize @idea, :pin?

      @idea.update!(pinned: true)

      respond_to do |format|
        format.html { redirect_to @idea, notice: "Idea has been pinned." }
        format.turbo_stream
      end
    end

    # DELETE /ideas/:idea_id/pin
    def destroy
      authorize @idea, :unpin?

      @idea.update!(pinned: false)

      respond_to do |format|
        format.html { redirect_to @idea, notice: "Idea has been unpinned." }
        format.turbo_stream
      end
    end

    private

      def set_idea
        @idea = Idea.find(params.expect(:idea_id))
      end
  end
end
