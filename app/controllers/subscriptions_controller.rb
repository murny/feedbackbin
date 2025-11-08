# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :require_authentication
  before_action :set_subscribable

  # POST /posts/:post_id/subscriptions
  def create
    @subscribable.subscribe(Current.user)

    respond_to do |format|
      format.html { redirect_back fallback_location: @subscribable, notice: t(".success") }
      format.turbo_stream
    end
  end

  # DELETE /posts/:post_id/subscriptions/:id
  def destroy
    @subscribable.unsubscribe(Current.user)

    respond_to do |format|
      format.html { redirect_back fallback_location: @subscribable, notice: t(".success") }
      format.turbo_stream
    end
  end

  private

    def set_subscribable
      if params[:post_id]
        @subscribable = Post.find(params[:post_id])
      else
        raise ActionController::RoutingError, "No subscribable found"
      end
    end
end
