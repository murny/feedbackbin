# frozen_string_literal: true

class ApplicationPolicy
  # We use Membership for policies because it contains roles for the current organization
  # This allows separate roles for each user and organization.
  #
  # Defaults:
  # - Allow admins
  # - Deny everyone else

  attr_reader :membership, :record

  def initialize(membership, record)
    # Uncomment to not allow guest users
    # raise Pundit::NotAuthorizedError, "must be logged in" unless membership

    @membership = membership
    @record = record
  end

  def index?
    admin?
  end

  def show?
    admin?
  end

  def create?
    admin?
  end

  def new?
    create?
  end

  def update?
    admin?
  end

  def edit?
    update?
  end

  def destroy?
    admin?
  end

  private

    def admin?
      membership&.administrator?
    end

  class Scope
    def initialize(membership, scope)
      # Uncomment to not allow guest users
      # raise Pundit::NotAuthorizedError, "must be logged in" unless membership

      @membership = membership
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

      attr_reader :membership, :scope
  end
end
