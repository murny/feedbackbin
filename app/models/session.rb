# frozen_string_literal: true

class Session < ApplicationRecord
  ACTIVITY_REFRESH_RATE = 1.hour

  belongs_to :identity
  belongs_to :current_account, class_name: "Account", optional: true

  before_create { self.last_active_at ||= Time.zone.now }

  def resume(user_agent:, ip_address:)
    if last_active_at.before?(ACTIVITY_REFRESH_RATE.ago)
      update! user_agent: user_agent, ip_address: ip_address, last_active_at: Time.zone.now
    end
  end

  def current?
    self == Current.session
  end

  # Get the user (membership) for the current account
  def user
    return nil unless current_account
    identity.user_for(current_account)
  end

  # Switch to a different account
  def switch_account!(account)
    raise ArgumentError, "Identity does not have access to this account" unless identity.accounts.include?(account)
    update!(current_account: account)
  end
end
