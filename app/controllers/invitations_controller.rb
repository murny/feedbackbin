# frozen_string_literal: true

class InvitationsController < ApplicationController
  allow_unauthenticated_access
  skip_after_action :verify_authorized

  before_action :set_invitation

  def show
    # Invitation exists, so it's pending (accepted invitations are deleted)
  end

  private

    def set_invitation
      @invitation = Invitation.find_by!(token: params[:token])
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: t("invitations.show.not_found")
    end
end
