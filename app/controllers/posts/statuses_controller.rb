# frozen_string_literal: true

module Posts
  class StatusesController < ApplicationController
    before_action :set_post

    # PATCH /posts/:post_id/status
    def update
      authorize @post, :update_status?

      old_status = @post.post_status
      post_status = PostStatus.find(params.expect(:post_status_id))
      @post.update!(post_status: post_status)

      # Notify subscribers and upvoters of status change
      if old_status != post_status
        PostStatusChangedNotification.with(
          post: @post,
          old_status: old_status,
          new_status: post_status,
          changed_by: Current.user
        ).deliver_later(@post.active_subscribers + @post.likes.map(&:voter))
      end

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
