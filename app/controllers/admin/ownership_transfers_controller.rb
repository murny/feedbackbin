# frozen_string_literal: true

module Admin
  class OwnershipTransfersController < Admin::BaseController
    before_action :ensure_owner

    def new
      @organization = Current.organization
      @administrators = User.administrator.where.not(id: @organization.owner_id)
    end

    def create
      @organization = Current.organization
      new_owner = User.find(params[:new_owner_id])

      unless new_owner.administrator?
        redirect_to new_admin_ownership_transfer_path, alert: t(".new_owner_must_be_admin") and return
      end

      if @organization.update(owner: new_owner)
        redirect_to admin_settings_branding_path, notice: t(".success", name: new_owner.name)
      else
        @administrators = User.administrator.where.not(id: @organization.owner_id)
        flash.now[:alert] = t(".failure")
        render :new, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound
      redirect_to new_admin_ownership_transfer_path, alert: t(".user_not_found")
    end

    private

    def ensure_owner
      authorize Current.organization, :transfer_ownership?
    end
  end
end
