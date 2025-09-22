# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def show?
    true
  end

  def destroy?
    owned? || admin?
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
