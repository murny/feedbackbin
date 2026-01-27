# frozen_string_literal: true

class CommentsController < ApplicationController
  allow_unauthenticated_access only: %i[show]
  skip_after_action :verify_authorized

  before_action :set_comment, only: %i[show edit update destroy]
  before_action :ensure_permission_to_administer_comment, only: %i[edit update destroy]

  def show
  end

  def edit
  end

  def create
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
      @comment = Current.account.comments.find(params.expect(:id))
    end

    def ensure_permission_to_administer_comment
      head :forbidden unless Current.user.can_administer_comment?(@comment)
    end

    def comment_params
      params.expect(comment: [ :body, :parent_id, :idea_id ])
    end
end
