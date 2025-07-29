# frozen_string_literal: true

class PostPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5

  def index?
    true
  end

  def show?
    true
  end

  def create?
    membership.present?
  end

  def new?
    create?
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

  def pin?
    admin?
  end

  def unpin?
    admin?
  end

  private

    def owned?
      record && membership && record.author == membership.user
    end

  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end
