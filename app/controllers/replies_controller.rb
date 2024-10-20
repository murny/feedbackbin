# frozen_string_literal: true

class RepliesController < ApplicationController
  allow_unauthenticated_access only: %i[show]
  before_action :set_reply, only: %i[show edit update destroy]
  before_action :set_comment, only: %i[create]

  def show
  end

  def edit
  end

  def create
    @reply = @comment.replies.new(reply_params)
    @reply.creator = Current.user

    respond_to do |format|
      if @reply.save
        reply = Reply.new
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("comment_#{@comment.id}_new_reply", partial: "replies/form", locals: {reply: reply, comment: @comment})
        }
        format.html { redirect_to @comment, notice: t(".successfully_created") }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("comment_#{@comment.id}_new_reply", partial: "replies/form", locals: {reply: @reply, comment: @comment})
        }
        format.html { redirect_to @comment, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @reply.update(reply_params)
      redirect_to @reply
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reply.destroy!
    respond_to do |format|
      format.turbo_stream {}
      format.html { redirect_to @reply.comment, status: :see_other, notice: t(".successfully_destroyed") }
      format.json { head :no_content }
    end
  end

  private

  def set_comment
    @comment = Comment.find(params[:reply][:comment_id])
  end

  def set_reply
    @reply = Reply.find(params.expect(:id))
  end

  def reply_params
    params.expect(reply: [:body])
  end
end
