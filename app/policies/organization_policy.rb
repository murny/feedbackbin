# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  def show?
    admin?
  end

  def new?
    # TODO: Anyone can create an organization for now if they are logged in
    # later on this would be gate kept by stripe or something?
    user.present?
  end

  def create?
    new?
  end

  def edit?
    admin?
  end

  def update?
    edit?
  end

  def destroy?
    edit?
  end
end
