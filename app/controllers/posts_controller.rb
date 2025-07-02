# frozen_string_literal: true

class PostsController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_post, only: %i[show edit update destroy]
  before_action :ensure_index_is_not_empty, only: %i[index]

  # GET /posts or /posts.json
  def index
    authorize Post

    @categories = Category.all
    @category = params[:category_id].present? ? Category.find(params[:category_id]) : Category.first
    @tags = Tag.popular.limit(20)
    
    posts_scope = @category.posts.includes(:author, :tags, :post_status, :category)
    posts_scope = posts_scope.with_tag(params[:tag]) if params[:tag].present?
    
    # Handle sorting with pinned posts always first
    sorted_posts = posts_scope.sort_by_params(params[:sort], sort_direction)
    @pagy, @posts = pagy(sorted_posts.order(pinned: :desc))
  end

  # GET /posts/1 or /posts/1.json
  def show
    authorize @post

    # Track page views (avoid tracking author's own views)
    if authenticated? && @post.author != Current.user
      @post.increment_view_count!
    elsif !authenticated?
      @post.increment_view_count!
    end

    @comment = Comment.new
  end

  # GET /posts/new
  def new
    authorize Post

    @post = Post.new
  end

  # GET /posts/1/edit
  def edit
    authorize @post
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
    permitted_params = params.expect(post: [ :title, :body, :category_id, :pinned, :status_color, tag_names: [] ])
    
    # Convert tag_names to proper format if present
    if permitted_params[:tag_names].present?
      permitted_params[:tag_names] = permitted_params[:tag_names].reject(&:blank?)
    end
    
    permitted_params
  end
end
