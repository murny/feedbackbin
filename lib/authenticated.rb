# frozen_string_literal: true

# This module provides a simple DSL for routing constraints based on user roles, similar to what Devise provides.
module Authenticated
  class StaffConstraint
    def matches?(request)
      if (session = Session.find_signed(request.cookie_jar.signed[:session_token]))
        session.identity.staff?
      else
        false
      end
    end
  end

  class AdminConstraint
    def matches?(request)
      if (session = Session.find_signed(request.cookie_jar.signed[:session_token]))
        session.identity.users.find_by(account: Current.account).admin?
      else
        false
      end
    end
  end

  class UserConstraint
    def matches?(request)
      if (session = Session.find_signed(request.cookie_jar.signed[:session_token]))
        session.identity
      else
        false
      end
    end
  end

  class ForbiddenConstraint
    def matches?(_request) = false
  end

  ROLES = {
    staff: StaffConstraint,
    admin: AdminConstraint,
    user: UserConstraint
  }

  def authenticated(role, &)
    constraints(constraint_for(role), &)
  end

  private

    def constraint_for(role)
      ROLES[role.to_sym]&.new || ForbiddenConstraint.new
    end
end
