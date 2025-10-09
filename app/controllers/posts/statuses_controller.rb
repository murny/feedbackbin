# frozen_string_literal: true

module Posts
  class StatusesController < ApplicationController
    before_action :set_post

    # PATCH /posts/:post_id/status
    def update
      authorize @post, :update_status?

      @post.update!(post_status_id: params.expect(:post_status_id))

      respond_to do |format|
        format.html { redirect_to @post, notice: t(".success") }
        format.turbo_stream
      end
    end

    private

      def set_post
        @post = Post.find(params.expect(:post_id))
      end
  end
end
