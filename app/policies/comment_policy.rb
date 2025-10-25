# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def show?
    true
  end

  def create?
    user.present?
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
      record && user && record.creator == user
    end

    class Scope < ApplicationPolicy::Scope
      # NOTE: Be explicit about which records you allow access to!
      # def resolve
      #   scope.all
      # end
    end
end
