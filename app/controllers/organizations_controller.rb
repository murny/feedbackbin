# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[show edit update destroy]


  # GET /organizations/1
  def show
    authorize @organization
  end

  # GET /organizations/new
  def new
    authorize Organization

    @organization = Organization.new
    @organization.categories.build
  end

  # GET /organizations/1/edit
  def edit
    authorize @organization
  end

  # POST /organizations
  def create
    authorize Organization

    @organization = Organization.new(organization_params.merge(owner: Current.user))

    if @organization.save
      redirect_to organization_url(@organization), notice: t(".successfully_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /organizations/1
  def update
    authorize @organization

    if @organization.update(organization_params)
      redirect_to organization_url(@organization), notice: t(".successfully_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /organizations/1
  def destroy
    authorize @organization

    @organization.destroy!

    redirect_to root_url, notice: t(".successfully_destroyed")
  end

  private

    def set_organization
      @organization = Organization.find(params[:id])
    end

  def organization_params
    params.require(:organization).permit(:name, :logo, categories_attributes: [ :id, :name ])
  end
end
