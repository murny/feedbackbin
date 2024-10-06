# frozen_string_literal: true

class CommentsController < ApplicationController
  include RecordHelper
  include ActionView::RecordIdentifier

  before_action :set_comment, only: %i[show edit update destroy]
  before_action :set_commentable, only: %i[create]

  def show
  end

  def edit
  end

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.creator = Current.user
    @comment.parent_id = @parent&.id

    respond_to do |format|
      if @comment.save
        comment = Comment.new
        format.turbo_stream {
          if @parent
            # A successful reply to another comment, replace and hide this form
            render turbo_stream: turbo_stream.replace(dom_id_for_records(@parent, comment), partial: "comments/form", locals: {comment: comment, commentable: @parent, data: {comment_reply_target: :form}, class: "hidden"})
          else
            render turbo_stream: turbo_stream.replace(dom_id_for_records(@commentable, comment), partial: "comments/form", locals: {comment: comment, commentable: @commentable})
          end
        }
        format.html { redirect_to @commentable, notice: t(".successfully_created") }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(dom_id_for_records(@parent || @commentable, @comment), partial: "comments/form", locals: {comment: @comment, commentable: @parent || @commentable})
        }
        format.html { redirect_to @commentable }
      end
    end
  end

  def update
    if @comment.update(comment_params)
      redirect_to @comment
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy!
    respond_to do |format|
      format.turbo_stream {}
      format.html { redirect_to @comment.commentable, status: :see_other, notice: t(".successfully_destroyed") }
      format.json { head :no_content }
    end
  end

  private

  def set_commentable
    if params[:comment][:commentable_type] == "Comment"
      @parent = Comment.find(params[:comment][:commentable_id])
      @commentable = @parent.commentable
    elsif params[:comment][:commentable_type] == "Post"
      @commentable = Post.find(params[:comment][:commentable_id])
    end
  end

  def set_comment
    @comment = Comment.find(params.expect(:id))
  end

  def comment_params
    params.expect(comment: [:body])
  end
end
