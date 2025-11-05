# frozen_string_literal: true

class InvitationsController < ApplicationController
  allow_unauthenticated_access
  skip_after_action :verify_authorized

  rate_limit to: 10, within: 1.minute, only: :show

  def show
    @invitation = Invitation.find_by!(token: params[:token])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t(".not_found")
  end
end
