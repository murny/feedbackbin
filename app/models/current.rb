# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :account

  delegate :user, to: :session, allow_nil: true

  def account=(value)
    super
    @account_user = nil
    @other_accounts = nil
  end

  def account_user
    return unless account
    @account_user ||= account.account_users.includes(:user).find_by(user: user)
  end

  def account_admin?
    !!account_user&.administrator?
  end

  def other_accounts
    @other_accounts ||= user.accounts.order(name: :asc).where.not(id: account.id)
  end
end
