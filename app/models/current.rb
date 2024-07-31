# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  def account
    Account.first
  end

  attribute :session
  delegate :user, to: :session, allow_nil: true
end
