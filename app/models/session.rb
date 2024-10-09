# frozen_string_literal: true

class Session < ApplicationRecord
  ACTIVITY_REFRESH_RATE = 1.hour

  belongs_to :user

  before_create { self.last_active_at ||= Time.zone.now }

  def resume(user_agent:, ip_address:)
    if last_active_at.before?(ACTIVITY_REFRESH_RATE.ago)
      update! user_agent: user_agent, ip_address: ip_address, last_active_at: Time.zone.now
    end
  end
end
