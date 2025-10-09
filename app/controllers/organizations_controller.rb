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

    ApplicationRecord.transaction do
      # Create all default post statuses
      PostStatus.create!([
        { name: "Open", color: "#3b82f6", position: 1 },
        { name: "Planned", color: "#8b5cf6", position: 2 },
        { name: "In Progress", color: "#f59e0b", position: 3 },
        { name: "Complete", color: "#10b981", position: 4 },
        { name: "Closed", color: "#ef4444", position: 5 }
      ])

      # Set default post status to first by position
      @organization.default_post_status = PostStatus.ordered.first
      @organization.save!
    end

    # Test that we can use flash messages here?
    redirect_to admin_root_url(subdomain: @organization.subdomain), allow_other_host: true, notice: t(".successfully_created")
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  private

    def organization_params
      params.require(:organization).permit(:name, :subdomain, :logo)
    end
end
