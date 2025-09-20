# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session

  delegate :user, to: :session, allow_nil: true

  def organization
    Organization.first
  end

  def membership
    @membership ||= organization.memberships.includes(:user).find_by(user: user)
  end

  def organization_admin?
    !!membership&.administrator?
  end
end
