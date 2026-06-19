# frozen_string_literal: true

class UnsubscribesController < ApplicationController
  allow_unauthenticated_access only: [ :show, :destroy_by_token ]
  skip_before_action :require_account, only: [ :show, :destroy_by_token ]
  skip_before_action :ensure_signup_completed, only: [ :show, :destroy_by_token ]

  # One-click unsubscribe must be callable from any origin (mail clients, RFC 8058
  # List-Unsubscribe-Post). The signed message_verifier token (watch_id + user_id +
  # idea_id, 30-day expiry, uniform 410 Gone on mismatch) replaces CSRF protection.
  skip_forgery_protection only: :destroy_by_token

  def show
    payload = verified_payload(params[:token])
    return render :expired, status: :gone if payload.blank?

    watch = find_watch(payload)
    return render :expired, status: :gone if watch.nil?

    @idea = watch.idea
  end

  def destroy_by_token
    payload = verified_payload(params[:token])
    return render :expired, status: :gone if payload.blank?

    watch = find_watch(payload)
    return render :expired, status: :gone if watch.nil?

    watch.update!(watching: false) if watch.watching?
    @idea = watch.idea
    render :done
  end

  private
    def verified_payload(token)
      Rails.application.message_verifier(:watch_unsubscribe).verified(token)&.with_indifferent_access
    end

    def find_watch(payload)
      Watch.find_by(id: payload[:watch_id], user_id: payload[:user_id], idea_id: payload[:idea_id])
    end
end
