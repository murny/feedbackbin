# frozen_string_literal: true

module Admin
  module Settings
    class OwnershipTransfersController < Admin::BaseController
      before_action :ensure_owner

      def new
        @account = Current.account
        @admins = User.admin
      end

      def create
        @account = Current.account
        new_owner = User.find(params[:new_owner_id])
        current_owner = User.owner.first!

        User.transaction do
          # Use update_column to skip validation since this is the legitimate ownership transfer
          current_owner.update_column(:role, "admin")
          new_owner.update!(role: :owner)
        end

        redirect_to admin_settings_branding_path, notice: t(".success", name: new_owner.name)
      rescue ActiveRecord::RecordInvalid
        @admins = User.admin
        flash.now[:alert] = t(".failure")
        render :new, status: :unprocessable_entity
      end
    end
  end
end
