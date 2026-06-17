# frozen_string_literal: true

class UnsubscribesController < ApplicationController
  allow_unauthenticated_access only: :destroy_by_token
  skip_before_action :require_account, only: :destroy_by_token
  skip_before_action :ensure_signup_completed, only: :destroy_by_token

  def destroy_by_token
    payload = Rails.application.message_verifier(:watch_unsubscribe).verified(params[:token])

    return render :expired, status: :gone if payload.blank?

    payload = payload.with_indifferent_access
    watch = Watch.find_by(id: payload[:watch_id], user_id: payload[:user_id], idea_id: payload[:idea_id])

    return render :expired, status: :gone if watch.nil?

    watch.update!(watching: false)
    @idea = watch.idea
    render :show
  end
end
