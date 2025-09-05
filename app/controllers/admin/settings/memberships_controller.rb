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

        @membership.destroy!

        if @membership.user == Current.user
          redirect_to root_path, notice: t(".successfully_left")
        else
          redirect_to admin_settings_memberships_path, notice: t(".successfully_destroyed")
        end
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
