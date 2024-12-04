class OrganizationInvitationPolicy < ApplicationPolicy
  def new?
    admin?
  end

  def create?
    new?
  end
end
