# frozen_string_literal: true

module Ideas
  class StatusesController < ApplicationController
    before_action :set_idea

    # PATCH /ideas/:idea_id/status
    def update
      authorize @idea, :update_status?

      status = Status.find(params.expect(:status_id))
      @idea.update!(status: status)

      respond_to do |format|
        format.html { redirect_to @idea, notice: t(".success") }
        format.turbo_stream
      end
    end

    private

      def set_idea
        @idea = Idea.find(params.expect(:idea_id))
      end
  end
end
