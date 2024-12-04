# frozen_string_literal: true

module Organizations
  class OrganizationInvitationsController < ApplicationController
    before_action :set_organization

    def new
      authorize OrganizationInvitation

      @organization_invitation = OrganizationInvitation.new(organization: @organization)
    end

    def create
      authorize OrganizationInvitation

      @organization_invitation = OrganizationInvitation.new(organization: @organization, invited_by: Current.user, **organization_invitation_params)

      if @organization_invitation.save
        redirect_to organization_memberships_path(@organization), notice: t(".successfully_created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    private

    def set_organization
      @organization = Current.user.organizations.find(params[:organization_id])
    end

    def organization_invitation_params
      params.require(:organization_invitation).permit(:email)
    end
  end
end
