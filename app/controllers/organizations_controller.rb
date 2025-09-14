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
      # TODO: We need to handle tenant handling better in general
      session[:organization_id] = @organization.id
      redirect_to admin_root_path, notice: t(".successfully_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    def organization_params
      params.require(:organization).permit(:name, :subdomain, :logo, categories_attributes: [ :id, :name ])
    end
end
