# frozen_string_literal: true

module SetCurrentAccount
  extend ActiveSupport::Concern

  included do
    before_action :set_current_account
  end

  private

  def set_current_account
    Current.account ||= account_from_domain || account_from_subdomain || account_from_param || account_from_session || fallback_account
  end

  def account_from_domain
    Account.includes(:users).find_by(domain: request.domain)
  end

  def account_from_subdomain
    return unless request.subdomains.size > 0
    Account.includes(:users).find_by(subdomain: request.subdomains.first)
  end

  def account_from_param
    return unless (account_id = params[:account_id].presence)
    Current.user.accounts.includes(:users).find_by(id: account_id)
  end

  def account_from_session
    return unless authenticated? && (account_id = session[:account_id])
    Current.user.accounts.includes(:users).find_by(id: account_id)
  end

  def fallback_account
    return unless authenticated?
    Current.user.accounts.includes(:users).order(created_at: :asc).first
  end
end
