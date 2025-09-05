# frozen_string_literal: true

module Admin
  module Settings
    class MembershipsController < Admin::BaseController
      before_action :set_membership, only: [ :edit, :update, :destroy ]

      def index
        authorize Membership

        @memberships = Current.organization.memberships.includes(:user)
      end

      def edit
        authorize @membership
      end

      def update
        authorize @membership

        if @membership.update(membership_params)
          redirect_to admin_settings_memberships_path, notice: t(".successfully_updated")
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        authorize @membership

        if @membership.organization_owner?
          return redirect_to admin_settings_memberships_path, alert: t(".owner_cannot_be_removed")
        end

        @membership.destroy!

        redirect_to admin_settings_memberships_path, notice: t(".successfully_destroyed")
      end

      private
        def set_membership
          @membership = Current.organization.memberships.find(params[:id])
        end

        def membership_params
          params.require(:membership).permit(:role)
        end
    end
  end
end
