# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def show?
    true
  end

  def destroy?
    return false if record.organization_owner?

    owned? || admin?
  end

  def update_role?
    return false unless admin?

    # Prevent updating the owner's role at all
    return false if record.organization_owner?

    true
  end

  private

    def owned?
      record && user && record == user
    end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
