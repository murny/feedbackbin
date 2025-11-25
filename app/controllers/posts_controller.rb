# frozen_string_literal: true

class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_post, only: %i[show edit update destroy]

  # GET /posts or /posts.json
  def index
    authorize Post

    posts = Post.includes(:author, :category, :post_status)
    @categories = Category.ordered
    @post_statuses = PostStatus.ordered
    @search = params[:search]

    if params[:category_id].present?
      @category = @categories.find_by(id: params[:category_id])
      posts = posts.where(category_id: @category.id) if @category
    end

    # Apply search filter using Post.search method
    posts = posts.search(@search)

    posts = posts.sort_by_params(sort_column(Post), sort_direction)

    # Apply status filtering if provided, otherwise default to visible on feedback
    if params[:post_status_id].present?
      posts = posts.where(post_status_id: params[:post_status_id])
    else
      # By default, only show posts with statuses visible on feedback page
      posts = posts.joins(:post_status).merge(PostStatus.visible_on_feedback)
    end

    # Order with pinned posts first
    posts = posts.ordered_with_pinned

    @pagy, @posts = pagy(posts)
  end

  # GET /posts/1 or /posts/1.json
  def show
    authorize @post

    @top_level_comments = @post.comments
                               .where(parent_id: nil)
                               .ordered
                               .includes(:creator, replies: :creator)

    @comment = Comment.new
  end

  # GET /posts/new
  def new
    authorize Post

    @post = Post.new

    @categories = Category.ordered

    if params[:category_id].present?
      @post.category = @categories.find_by(id: params[:category_id])
    end
  end

  # GET /posts/1/edit
  def edit
    authorize @post

    @categories = Category.ordered
  end

  # POST /posts or /posts.json
  def create
    authorize Post

    @post = Post.new(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to post_path(@post), notice: t(".successfully_created") }
        format.json { render :show, status: :created, location: @post }
      else
        format.html do
          @categories = Category.ordered

          render :new, status: :unprocessable_entity
        end
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /posts/1 or /posts/1.json
  def update
    authorize @post

    respond_to do |format|
      if @post.update(post_params)
        format.html { redirect_to post_path(@post), notice: t(".successfully_updated") }
        format.json { render :show, status: :ok, location: @post }
      else
        format.html do
          @categories = Category.ordered

          render :edit, status: :unprocessable_entity
        end
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1 or /posts/1.json
  def destroy
    authorize @post

    @post.destroy!

    respond_to do |format|
      format.html { redirect_to posts_path, status: :see_other, notice: t(".successfully_destroyed") }
      format.json { head :no_content }
    end
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_post
      @post = Post.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.expect(post: [ :title, :body, :category_id ])
    end
end
