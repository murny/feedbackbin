# frozen_string_literal: true

class RepliesController < ApplicationController
  allow_unauthenticated_access only: %i[show]
  before_action :set_reply, only: %i[show edit update destroy]
  before_action :set_parent, only: %i[create]

  def show
  end

  def edit
  end

  def create
    @reply = Comment.new(reply_params)
    @reply.creator = Current.user

    binding.irb

    respond_to do |format|
      if @reply.save
        reply = Comment.new
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("comment_#{@parent.id}_new_reply", partial: "replies/form", locals: {reply: reply, parent: @parent})
        }
        format.html { redirect_to @parent, notice: t(".successfully_created") }
      else
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace("comment_#{@parent.id}_new_reply", partial: "replies/form", locals: {reply: @reply, parent: @parent})
        }
        format.html { redirect_to @parent, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @reply.update(reply_params)
      redirect_to reply_path(@reply), notice: t(".successfully_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reply.destroy!
    respond_to do |format|
      format.turbo_stream {}
      format.html { redirect_to @reply.post, status: :see_other, notice: t(".successfully_destroyed") }
      format.json { head :no_content }
    end
  end

  private

  def set_parent
    @parent = Comment.find(params[:comment][:parent_id])
  end

  def set_reply
    @reply = Comment.find(params.expect(:id))
  end

  def reply_params
    params.expect(comment: [:body, :parent_id, :post_id])
  end
end
