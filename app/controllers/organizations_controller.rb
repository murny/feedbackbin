# frozen_string_literal: true

class OrganizationsController < ApplicationController
  # GET /organizations/new
  def new
    authorize Organization

    @organization = Organization.new
    @organization.categories.build
  end

  # POST /organizations
  def create
    authorize Organization

    @organization = Organization.new(organization_params.merge(owner: Current.user))

    if @organization.save
      redirect_to admin_root_path, notice: t(".successfully_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    def organization_params
      params.require(:organization).permit(:name, :logo, categories_attributes: [ :id, :name ])
    end
end
