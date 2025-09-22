# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session

  delegate :user, to: :session, allow_nil: true

  def organization
    Organization.first
  end

  def admin?
    !!user&.administrator?
  end
end
