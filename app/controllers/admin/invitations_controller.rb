# frozen_string_literal: true

module Admin
  class InvitationsController < Admin::BaseController
    def index
      @pending_invitations = Invitation.pending.includes(:invited_by).order(created_at: :desc)
      @accepted_invitations = Invitation.accepted.includes(:invited_by, :accepted_by).order(accepted_at: :desc).limit(20)
    end

    def new
      @invitation = Invitation.new
    end

    def create
      @invitation = Invitation.new(invited_by: Current.user, **invitation_params)

      if @invitation.save_and_send_invite
        redirect_to admin_invitations_path, notice: t(".successfully_sent")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @invitation = Invitation.find(params[:id])

      if @invitation.pending? || @invitation.expired?
        @invitation.destroy
        redirect_to admin_invitations_path, notice: t(".successfully_cancelled")
      else
        redirect_to admin_invitations_path, alert: t(".cannot_cancel_accepted")
      end
    end

    private

      def invitation_params
        params.require(:invitation).permit(:email, :name)
      end
  end
end
