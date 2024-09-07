# frozen_string_literal: true

class AdminConstraint
  def matches?(request)
    if (session = Session.find_by(id: request.cookie_jar.signed[:session_id]))
      session.user.can_administer?
    else
      false
    end
  end
end
