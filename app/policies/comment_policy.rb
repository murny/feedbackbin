# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    membership.present?
  end

  def update?
    owned? || admin?
  end

  def edit?
    update?
  end

  def destroy?
    owned? || admin?
  end

  private

    def owned?
      record && membership && record.creator == membership.user
    end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
