# frozen_string_literal: true

class Session < ApplicationRecord
  ACTIVITY_REFRESH_RATE = 1.hour
  EXPIRATION_TIME = 30.days

  belongs_to :user

  before_create { self.last_active_at ||= Time.zone.now }

  scope :expired, -> { where("last_active_at < ?", EXPIRATION_TIME.ago) }

  def resume(user_agent:, ip_address:)
    if last_active_at.before?(ACTIVITY_REFRESH_RATE.ago)
      update! user_agent: user_agent, ip_address: ip_address, last_active_at: Time.zone.now
    end
  end

  def current?
    self == Current.session
  end

  # Cleanup expired sessions
  def self.cleanup_expired(older_than: EXPIRATION_TIME.ago)
    where("last_active_at < ?", older_than).delete_all
  end
end
