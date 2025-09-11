# frozen_string_literal: true

module Admin
  module Settings
    class OrganizationInvitationsController < Admin::BaseController
      def index
        @organization_invitations = Current.organization.organization_invitations.includes(:invited_by).order(created_at: :desc)
      end

      def new
        @organization_invitation = OrganizationInvitation.new(organization: Current.organization)
      end

      def create
        @organization_invitation = OrganizationInvitation.new(organization: Current.organization, invited_by: Current.user, **organization_invitation_params)

        if @organization_invitation.save
          redirect_to admin_settings_organization_invitations_path, notice: t(".successfully_created")
        else
          render :new, status: :unprocessable_entity
        end
      end

      def destroy
        @organization_invitation = Current.organization.organization_invitations.find(params[:id])

        @organization_invitation.destroy
        redirect_to admin_settings_organization_invitations_path, notice: t(".successfully_destroyed")
      end

      private

        def organization_invitation_params
          params.require(:organization_invitation).permit(:email, :name)
        end
    end
  end
end
