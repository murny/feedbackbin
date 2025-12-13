# frozen_string_literal: true

class Current < ActiveSupport::CurrentAttributes
  attribute :session, :account

  # Keep the generated `account` accessor as a separate method so we can
  # safely override `account` while still supporting `Current.account = ...`
  alias_method :explicit_account, :account

  def identity
    session&.identity
  end

  def user
    session&.user
  end

  def account
    explicit_account || session&.current_account
  end

  def admin?
    !!user&.admin?
  end

  def super_admin?
    !!identity&.super_admin?
  end

  # List of accounts the current identity has access to
  def accounts
    identity&.accounts || Account.none
  end
end
