# frozen_string_literal: true

class IdeasController < ApplicationController
  allow_unauthenticated_access only: %i[index show]

  before_action :set_idea, only: %i[show edit update destroy]
  before_action :set_boards, only: %i[index new edit create update]
  before_action :ensure_permission_to_administer_idea, only: %i[edit update destroy]

  # GET /ideas or /ideas.json
  def index
    ideas = Current.account.ideas.includes(:creator, :board, :status, :tags, comments: :creator)
    @statuses = Status.ordered
    @search = params[:search]

    if params[:board_id].present?
      @board = @boards.find_by(id: params[:board_id])
      ideas = ideas.where(board_id: @board.id) if @board
    end

    # Apply search filter using Idea.search method
    ideas = ideas.search(@search)

    ideas = ideas.sort_by_params(sort_column(Idea), sort_direction)

    # Apply status filtering if provided, otherwise default to visible on idea
    if params[:status_id].present?
      ideas = ideas.where(status_id: params[:status_id])
    else
      # By default, only show ideas with statuses visible on idea page OR open ideas (no status)
      ideas = ideas.left_outer_joins(:status).where(statuses: { show_on_idea: true }).or(
        ideas.left_outer_joins(:status).where(status_id: nil)
      )
    end

    # Order with pinned ideas first
    ideas = ideas.ordered_with_pinned

    @pagy, @ideas = pagy(ideas)
  end

  # GET /ideas/1 or /ideas/1.json
  def show
    @comment_sort = params[:comment_sort]&.to_sym || :oldest

    @top_level_comments = @idea.comments
                             .top_level
                             .sorted_by(@comment_sort)
                             .includes(:creator, replies: :creator)

    @comment = Comment.new
  end

  # GET /ideas/new
  def new
    @idea = Idea.new

    if params[:board_id].present?
      @idea.board = @boards.find_by(id: params[:board_id])
    end
  end

  # GET /ideas/1/edit
  def edit
  end

  # POST /ideas or /ideas.json
  def create
    @idea = Idea.new(idea_params)

    respond_to do |format|
      if @idea.save
        format.html { redirect_to idea_path(@idea), notice: t(".successfully_created") }
        format.json { render :show, status: :created, location: @idea }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ideas/1 or /ideas/1.json
  def update
    respond_to do |format|
      if @idea.update(idea_params)
        format.html { redirect_to idea_path(@idea), notice: t(".successfully_updated") }
        format.json { render :show, status: :ok, location: @idea }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @idea.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ideas/1 or /ideas/1.json
  def destroy
    @idea.destroy!

    respond_to do |format|
      format.html { redirect_to ideas_path, status: :see_other, notice: t(".successfully_destroyed") }
      format.json { head :no_content }
    end
  end

  private

    def set_idea
      @idea = Current.account.ideas.includes(:tags).find(params.expect(:id))
    end

    def set_boards
      @boards = Board.ordered
    end

    def ensure_permission_to_administer_idea
      head :forbidden unless Current.user&.can_administer_idea?(@idea)
    end

    def idea_params
      params.expect(idea: [ :title, :description, :board_id ])
    end
end
