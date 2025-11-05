# frozen_string_literal: true

module Admin
  class InvitationsController < Admin::BaseController
    def index
      invitations = Invitation.includes(:invited_by).order(created_at: :desc)
      @pagy, @invitations = pagy(invitations)
    end

    def new
      @invitation = Invitation.new
    end

    def create
      @invitation = Invitation.new(invitation_params)

      if @invitation.save_and_send_invite
        redirect_to admin_invitations_path, notice: t(".successfully_sent"), status: :see_other
      else
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      @invitation = Invitation.find_by!(token: params.expect(:id))

      @invitation.destroy

      respond_to do |format|
        format.html { redirect_to admin_invitations_path, notice: t(".successfully_cancelled") }
        format.turbo_stream do
          flash.now[:notice] = t(".successfully_cancelled")
          invitations = Invitation.includes(:invited_by).order(created_at: :desc)
          @pagy, @invitations = pagy(invitations)
        end
      end
    end

    private

      def invitation_params
        params.require(:invitation).permit(:email, :name).merge(invited_by: Current.user)
      end
  end
end
