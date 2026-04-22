# frozen_string_literal: true

module Ideas
  class CommentLocksController < ApplicationController
    include IdeaScoped
    before_action :ensure_admin

    # POST /ideas/:idea_id/comment_lock
    def create
      @idea.update!(comments_locked: true)

      respond_to do |format|
        format.html { redirect_to @idea, notice: t(".locked") }
        format.turbo_stream
      end
    end

    # DELETE /ideas/:idea_id/comment_lock
    def destroy
      @idea.update!(comments_locked: false)

      respond_to do |format|
        format.html { redirect_to @idea, notice: t(".unlocked") }
        format.turbo_stream
      end
    end
  end
end
