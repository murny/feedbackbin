# frozen_string_literal: true

class InvitationsController < ApplicationController
  allow_unauthenticated_access
  skip_after_action :verify_authorized

  before_action :set_invitation

  def show
    if @invitation.accepted?
      redirect_to root_path, notice: t(".already_accepted")
    end
  end

  private

    def set_invitation
      @invitation = Invitation.find_by!(token: params[:token])
    end
end
