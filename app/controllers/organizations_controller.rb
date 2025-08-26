# frozen_string_literal: true

class OrganizationsController < ApplicationController
  before_action :set_organization, only: %i[show edit update destroy]

  # GET /organizations
  def index
    authorize Organization

    @organizations = Current.user.organizations.includes(:users).search(params[:search]).sorted
  end

  # GET /organizations/1
  def show
    authorize @organization

    # Dashboard metrics
    @posts_count = @organization.posts.count
    @members_count = @organization.users.count
    @recent_posts = @organization.posts.includes(:author, :category, :post_status)
                                     .order(created_at: :desc)
                                     .limit(5)

    @recent_memberships = @organization.memberships
                                       .includes(:user)
                                       .order(created_at: :desc)
                                       .limit(5)
  end

  # GET /organizations/new
  def new
    authorize Organization

    @organization = Organization.new
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

    redirect_to organizations_url, notice: t(".successfully_destroyed")
  end

  private

    def set_organization
      @organization = Organization.find(params[:id])
    end

  def organization_params
    params.require(:organization).permit(:name, :logo)
  end
end
