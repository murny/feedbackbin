# frozen_string_literal: true

class CommentsController < ApplicationController
  allow_unauthenticated_access only: %i[show]
  before_action :set_comment, only: %i[show edit update destroy]
  before_action :set_post, only: %i[create]

  def show
  end

  def edit
  end

  def create
    @comment = @post.comments.new(comment_params)
    @comment.creator = Current.user

    respond_to do |format|
      if @comment.save
        comment = Comment.new
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("post_#{@post.id}_new_comment", partial: "comments/form", locals: {comment: comment, post: @post})
        }
        format.html { redirect_to @post, notice: t(".successfully_created") }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("post_#{@post.id}_new_comment", partial: "comments/form", locals: {comment: @comment, post: @post})
        }
        format.html { redirect_to @post }
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
      format.html { redirect_to @comment.post, status: :see_other, notice: t(".successfully_destroyed") }
      format.json { head :no_content }
    end
  end

  private

  def set_post
    @post = Post.find(params[:comment][:post_id])
  end

  def set_comment
    @comment = Comment.find(params.expect(:id))
  end

  def comment_params
    params.expect(comment: [:body])
  end
end
