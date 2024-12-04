# frozen_string_literal: true

class OrganizationPolicy < ApplicationPolicy
  def index?
    membership.present?
  end

  def show?
    record.memberships.include?(membership)
  end

  def new?
    true # TODO: Anyone can create an organization for now, later on this would be gate kept by stripe or something?
  end

  def create?
    admin?
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
