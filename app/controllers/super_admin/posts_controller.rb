# frozen_string_literal: true

module SuperAdmin
  class PostsController < SuperAdmin::BaseController
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
      @post = Post.includes(
                :category,
                :post_status,
                :rich_text_body,
                author: { avatar_attachment: :blob },
                organization: { logo_attachment: :blob }).find(params.expect(:id))

      @recent_comments = @post.comments.includes(:rich_text_body, creator: { avatar_attachment: :blob }).limit(5).order(created_at: :desc)
    end
  end
end
