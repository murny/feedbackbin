# frozen_string_literal: true

class Ideas::CommentsController < ApplicationController
  include IdeaScoped

  allow_unauthenticated_access only: %i[show]

  before_action :set_comment, only: %i[show edit update destroy]
  before_action :ensure_permission_to_administer_comment, only: %i[edit update destroy]

  def show
    render "comments/show"
  end

  def edit
    render "comments/edit"
  end

  def create
    @comment = @idea.comments.new(comment_params)

    respond_to do |format|
      if @comment.save
        notice = t(".successfully_created")
        format.html do
          flash[:notice] = notice
          redirect_to idea_path(@idea)
        end
        format.turbo_stream do
          flash.now[:notice] = notice
          render "comments/create"
        end
        format.json { render "comments/show", status: :created, location: idea_comment_path(@idea, @comment) }
      else
        format.html { render "comments/new", status: :unprocessable_entity }
        format.turbo_stream { render "comments/create" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @comment.update(comment_params)
        notice = t(".successfully_updated")
        format.html do
          flash[:notice] = notice
          redirect_to idea_comment_path(@idea, @comment)
        end
        format.turbo_stream do
          flash.now[:notice] = notice
          render "comments/update"
        end
        format.json { render "comments/show", status: :ok, location: idea_comment_path(@idea, @comment) }
      else
        format.html { render "comments/edit", status: :unprocessable_entity }
        format.turbo_stream { render "comments/update" }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @comment.destroy!
    notice = t(".successfully_destroyed")

    respond_to do |format|
      format.html do
        flash[:notice] = notice
        redirect_to @idea, status: :see_other
      end
      format.turbo_stream do
        flash.now[:notice] = notice
        render "comments/destroy"
      end
      format.json { head :no_content }
    end
  end

  private

    def set_comment
      @comment = @idea.comments.find(params.expect(:id))
    end

    def ensure_permission_to_administer_comment
      head :forbidden unless Current.user&.can_administer_comment?(@comment)
    end

    def comment_params
      params.expect(comment: [ :body, :parent_id ])
    end
end
