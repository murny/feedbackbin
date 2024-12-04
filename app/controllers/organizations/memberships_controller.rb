# frozen_string_literal: true

module Organizations
  class MembershipsController < ApplicationController
    before_action :set_organization
    before_action :set_membership, only: [:edit, :update, :destroy]

    def index
      authorize Membership

      @memberships = @organization.memberships.includes(:user)
    end

    def edit
      authorize @membership
    end

    def update
      authorize @membership

      if @membership.update(membership_params)
        redirect_to organization_memberships_path(@organization), notice: "User updated"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @membership

      if @membership.try_destroy
        if @membership.user == Current.user
          redirect_to organizations_path, notice: "You have left that organization"
        else
          redirect_to organization_memberships_path(@organization), notice: "User removed from organization"
        end
      else
        redirect_to organization_memberships_path(@organization), alert: "Failed to remove user from organization"
      end
    end

    private

    def set_organization
      @organization = Current.user.organizations.find(params[:organization_id])
    end

    def set_membership
      @membership = @organization.memberships.find(params[:id])
    end

    def membership_params
      params.require(:membership).permit(:role)
    end
  end
end
