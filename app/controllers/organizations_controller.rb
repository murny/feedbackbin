# frozen_string_literal: true

class OrganizationsController < ApplicationController
  # GET /organizations/new
  def new
    authorize Organization

    @organization = Organization.new
  end

  # POST /organizations
  def create
    authorize Organization

    @organization = Organization.new(organization_params)

    if @organization.save
      # Test that we can use flash messages here?
      redirect_to admin_root_url(subdomain: @organization.subdomain), allow_other_host: true, notice: t(".successfully_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    def organization_params
      params.require(:organization).permit(:name, :subdomain, :logo)
    end
end
