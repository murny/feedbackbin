# frozen_string_literal: true

module Admin
  module Settings
    class OwnershipTransfersController < Admin::BaseController
      before_action :ensure_owner

      def new
        @organization = Current.organization
        @admins = User.admin.where.not(id: @organization.owner_id)
      end

      def create
        @organization = Current.organization
        new_owner = User.find(params[:new_owner_id])

        if @organization.update(owner: new_owner)
          redirect_to admin_settings_branding_path, notice: t(".success", name: new_owner.name)
        else
          @admins = User.admin.where.not(id: @organization.owner_id)
          flash.now[:alert] = t(".failure")
          render :new, status: :unprocessable_entity
        end
      end

      private

        def ensure_owner
          authorize Current.organization, :transfer_ownership?
        end
    end
  end
end
