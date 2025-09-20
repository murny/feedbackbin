# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session
  
  delegate :user, to: :session, allow_nil: true
  
  def organization
    return nil if ActiveRecord::Tenanted.current_tenant.blank?
    @organization ||= Organization.find_by(subdomain: ActiveRecord::Tenanted.current_tenant)
  end
  
  def organization_id
    organization&.id
  end

  # Organization is now determined by tenant context, not directly settable
  private
  
  def clear_cached_values
    @organization = nil
    @membership = nil
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
end
