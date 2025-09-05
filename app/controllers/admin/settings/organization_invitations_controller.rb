# frozen_string_literal: true

module Admin
  module Settings
    class OrganizationInvitationsController < Admin::BaseController
      def new
        authorize OrganizationInvitation

        @organization_invitation = OrganizationInvitation.new(organization: Current.organization)
      end

      def create
        authorize OrganizationInvitation

        @organization_invitation = OrganizationInvitation.new(organization: Current.organization, invited_by: Current.user, **organization_invitation_params)

        if @organization_invitation.save
          redirect_to admin_settings_memberships_path, notice: t(".successfully_created")
        else
          render :new, status: :unprocessable_entity
        end
      end

      private

        def organization_invitation_params
          params.require(:organization_invitation).permit(:email, :name)
        end
    end
  end
end
