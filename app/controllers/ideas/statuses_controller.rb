# frozen_string_literal: true

module Ideas
  class StatusesController < ApplicationController
    include IdeaScoped
    before_action :ensure_admin

    # PATCH /ideas/:idea_id/status
    def update
      status = Status.find(params.expect(:status_id))
      @idea.update!(status: status)

      respond_to do |format|
        format.html { redirect_to @idea, notice: t(".success") }
        format.turbo_stream
      end
    end
  end
end
