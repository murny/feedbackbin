# frozen_string_literal: true

# This module provides a simple DSL for routing constraints based on user roles, similar to what Devise provides.
module Authenticated
  class AdminConstraint
    def matches?(request)
      if (session = Session.find_by(id: request.cookie_jar.signed[:session_id]))
        session.user.site_admin?
      else
        false
      end
    end
  end

  class UserConstraint
    def matches?(request)
      if (session = Session.find_by(id: request.cookie_jar.signed[:session_id]))
        session.user
      else
        false
      end
    end
  end

  class ForbiddenConstraint
    def matches?(_request) = false
  end

  ROLES = {
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
