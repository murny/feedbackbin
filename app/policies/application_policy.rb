# frozen_string_literal: true

class ApplicationPolicy
  # We use AccountUser for policies because it contains roles for the current account
  # This allows separate roles for each user and account.
  #
  # Defaults:
  # - Allow admins
  # - Deny everyone else

  attr_reader :account_user, :record

  def initialize(account_user, record)
    # Uncomment to not allow guest users
    # raise Pundit::NotAuthorizedError, "must be logged in" unless account_user

    @account_user = account_user
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
    account_user&.administrator?
  end

  class Scope
    def initialize(account_user, scope)
      # Uncomment to not allow guest users
      # raise Pundit::NotAuthorizedError, "must be logged in" unless account_user

      @account_user = account_user
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :account_user, :scope
  end
end
