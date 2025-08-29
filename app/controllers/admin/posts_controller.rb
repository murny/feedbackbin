# frozen_string_literal: true

module Admin
  class PostsController < BaseController
    def index
      posts = Post.includes(:author, :organization, :category)
                  .search(params[:search])
                  .order(created_at: :desc)

      @pagy, @posts = pagy(posts)

      respond_to do |format|
        format.html
        format.turbo_stream { render "index" }
      end
    end

    def show
      @post = Post.find(params[:id])
      @recent_comments = @post.comments.includes(:creator).limit(5)
    end
  end
end
