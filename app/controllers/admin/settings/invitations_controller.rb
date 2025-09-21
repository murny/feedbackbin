# frozen_string_literal: true

module Admin
  module Settings
    class InvitationsController < Admin::BaseController
      def index
        @invitations = Current.organization.invitations.includes(:invited_by).order(created_at: :desc)
      end

      def new
        @invitation = Invitation.new
      end

      def create
        @invitation = Invitation.new(invited_by: Current.user, **invitation_params)

        if @invitation.save
          redirect_to admin_settings_invitations_path, notice: t(".successfully_created")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def destroy
        @invitation = Current.organization.invitations.find(params[:id])

        @invitation.destroy
        redirect_to admin_settings_invitations_path, notice: t(".successfully_destroyed")
      end

      private

        def invitation_params
          params.require(:invitation).permit(:email, :name)
        end
    end
  end
end
