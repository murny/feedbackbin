# frozen_string_literal: true

class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_post, only: %i[show edit update destroy]
  before_action :ensure_index_is_not_empty, only: %i[index]

  # GET /posts or /posts.json
  def index
    authorize Post

    posts = Current.organization.posts
    @categories = Current.organization.categories.order(:name)
    @post_statuses = Current.organization.post_statuses.order(:position)

    if params[:category_id].present?
      @category = @categories.find_by(id: params[:category_id])
      posts = posts.where(category_id: @category.id) if @category
    end

    posts = posts.sort_by_params(sort_column(Post), sort_direction)

    # Apply status filtering if provided
    if params[:post_status_id].present?
      posts = posts.where(post_status_id: params[:post_status_id])
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

    @categories = Current.organization.categories.order(:name)

    if params[:category_id].present?
      @post.category = @categories.find_by(id: params[:category_id])
    end
  end

  # GET /posts/1/edit
  def edit
    authorize @post

    @categories = Current.organization.categories.order(:name)
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
        format.html { render :new, status: :unprocessable_entity }
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
        format.html { render :edit, status: :unprocessable_entity }
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

    def ensure_index_is_not_empty
      if !authenticated? && Category.none?
        require_authentication
      end
    end

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def post_params
    params.expect(post: [ :title, :body, :category_id ])
  end
end
