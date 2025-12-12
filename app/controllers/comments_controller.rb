# frozen_string_literal: true

class CommentsController < ApplicationController
  allow_unauthenticated_access only: %i[show]
  before_action :set_comment, only: %i[show edit update destroy]

  def show
    authorize @comment
  end

  def edit
    authorize @comment
  end

  def create
    authorize Comment
    @comment = Comment.new(comment_params)

    respond_to do |format|
      if @comment.save
        flash.now[:notice] = t(".successfully_created")
        format.html { redirect_to idea_path(@comment.idea) }
        format.json { render :show, status: :created, location: @comment }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
      format.turbo_stream
    end
  end

  def update
    authorize @comment

    respond_to do |format|
      if @comment.update(comment_params)
        flash.now[:notice] = t(".successfully_updated")
        format.html { redirect_to @comment }
        format.json { render :show, status: :ok, location: @comment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @comment.errors, status: :unprocessable_entity }
      end
      format.turbo_stream
    end
  end

  def destroy
    authorize @comment

    @comment.destroy!
    respond_to do |format|
      flash.now[:notice] = t(".successfully_destroyed")
      format.turbo_stream { }
      format.html { redirect_to @comment.idea, status: :see_other }
      format.json { head :no_content }
    end
  end

  private

    def set_comment
      @comment = Comment.find(params.expect(:id))
    end

    def comment_params
      params.expect(comment: [ :body, :parent_id, :idea_id ])
    end
end
