# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session

  delegate :user, to: :session, allow_nil: true

  def account
    Account.first
  end

  def admin?
    !!user&.admin?
  end
end
