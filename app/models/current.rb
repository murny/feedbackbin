# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :organization

  delegate :user, to: :session, allow_nil: true

  def organization=(value)
    super
    @membership = nil
    @other_organizations = nil
  end

  def membership
    return unless organization

    # TODO: Need to revisit this.
    # find_or_create_by is used because organizations are typically public and users can join them without an invitation
    @membership ||= organization.memberships.includes(:user).find_or_create_by(user: user)
  end

  def organization_admin?
    !!membership&.administrator?
  end

  def other_organizations
    @other_organizations ||= if user.present?
      user.organizations.order(name: :asc).where.not(id: organization.id)
    else
      Organization.none
    end
  end
end
