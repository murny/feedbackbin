# frozen_string_literal: true

class Organizations::MembershipsController < ApplicationController
  before_action :set_organization
  before_action :set_membership, only: [:edit, :update, :destroy]

  def index
    authorize Membership

    @memberships = @organization.memberships.includes(:user)
  end

  def new
    authorize Membership

    @form = MembershipInvitation.new(organization: @organization, role: Membership.roles[:member])
  end

  def edit
    authorize @membership
  end

  def create
    authorize Membership

    @form = MembershipInvitation.new(email: params.dig(:membership_invitation, :email), role: params.dig(:membership_invitation, :role), organization: @organization, inviter: Current.user)

    if @form.save
      redirect_to organization_memberships_path(@organization), notice: "#{@form.email} invited!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @membership

    if @membership.update(membership_params)
      redirect_to organization_memberships_path(@organization), notice: "User updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @membership

    if @membership.try_destroy
      if @membership.user == Current.user
        redirect_to organizations_path, notice: "You have left that organization"
      else
        redirect_to organization_memberships_path(@organization), notice: "User removed from organization"
      end
    else
      redirect_to organization_memberships_path(@organization), alert: "Failed to remove user from organization"
    end
  end

  private

  def set_organization
    @organization = Current.organization
  end

  def set_membership
    @membership = @organization.memberships.find(params[:id])
    authorize @membership
  end

  def membership_params
    params.require(:membership).permit(:role)
  end
end
