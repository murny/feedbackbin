# frozen_string_literal: true

module Posts
  class PinsController < ApplicationController
    before_action :set_post

    # POST /posts/:post_id/pin
    def create
      authorize @post, :pin?

      @post.update!(pinned: true)

      respond_to do |format|
        format.html { redirect_to @post, notice: "Post has been pinned." }
        format.turbo_stream
      end
    end

    # DELETE /posts/:post_id/pin
    def destroy
      authorize @post, :unpin?

      @post.update!(pinned: false)

      respond_to do |format|
        format.html { redirect_to @post, notice: "Post has been unpinned." }
        format.turbo_stream
      end
    end

    private

      def set_post
        @post = Post.find(params.expect(:post_id))
      end
  end
end
