# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session
  delegate :user, to: :session, allow_nil: true

  # attribute :user, :account, :request_id, :user_agent, :ip_address

  # resets do
  #   Time.zone = nil
  # end

  # def user=(value)
  #   super
  #   Time.zone = Time.find_zone(value&.time_zone)
  # end

  # def account=(value)
  #   super
  #   @account_user = nil
  #   @other_accounts = nil
  # end

  # def account_user
  #   return unless account
  #   @account_user ||= account.account_users.includes(:user).find_by(user: user)
  # end

  # def roles
  #   Array.wrap(account_user&.active_roles)
  # end

  # def account_admin?
  #   !!account_user&.admin?
  # end

  # def other_accounts
  #   @other_accounts ||= user.accounts.order(name: :asc).where.not(id: account.id)
  # end
end
