# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session, :organization
  attribute :request_id, :user_agent, :ip_address

  delegate :user, to: :session, allow_nil: true

  def admin?
    !!user&.administrator?
  end

  # Helper method to execute a block with a specific organization context
  # Useful for background jobs or multi-tenant operations
  def with_organization(organization, &block)
    set(organization: organization, &block)
  end

  # Helper method to execute a block without organization context
  def without_organization(&block)
    set(organization: nil, &block)
  end
end
