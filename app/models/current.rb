# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :account
  attribute :http_method, :request_id, :user_agent, :ip_address, :referrer

  delegate :user, to: :session, allow_nil: true

  def account
    Account.first
  end

  def admin?
    !!user&.admin?
  end
end
