# frozen_string_literal: true

class ApplicationPolicy
  # We use User for policies with role-based authorization
  #
  # Defaults:
  # - Allow admins
  # - Deny everyone else

  attr_reader :user, :record

  def initialize(user, record)
    # Uncomment to not allow guest users
    # raise Pundit::NotAuthorizedError, "must be logged in" unless user

    @user = user
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
      user&.admin?
    end

    class Scope
      def initialize(user, scope)
        # Uncomment to not allow guest users
        # raise Pundit::NotAuthorizedError, "must be logged in" unless user

        @user = user
        @scope = scope
      end

      def resolve
        scope.all
      end

      private

        attr_reader :user, :scope
    end
end
