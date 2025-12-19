# frozen_string_literal: true

class Session < ApplicationRecord
  ACTIVITY_REFRESH_RATE = 1.hour

  belongs_to :identity

  before_create { self.last_active_at ||= Time.current }

  def resume(user_agent:, ip_address:)
    if last_active_at.before?(ACTIVITY_REFRESH_RATE.ago)
      update! user_agent: user_agent, ip_address: ip_address, last_active_at: Time.current
    end
  end

  def current?
    self == Current.session
  end
end
