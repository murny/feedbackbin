# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user_agent, :ip_address

  attribute :account

  delegate :user, to: :session, allow_nil: true

  def session=(session)
    super
    self.account = session.user.account
  end
end
