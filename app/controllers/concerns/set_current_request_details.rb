module SetCurrentRequestDetails
  extend ActiveSupport::Concern

  included do |base|
    if base < ActionController::Metal
      set_current_tenant_through_filter if defined? ActsAsTenant
      before_action :set_request_details
    end
  end

  def set_request_details
    Current.request_id = request.uuid
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
    Current.user = current_user

    # Account may already be set by the AccountMiddleware
    Current.account ||= account_from_domain || account_from_subdomain || account_from_param || account_from_session || fallback_account

    set_current_tenant(Current.account) if defined? ActsAsTenant
  end

  def account_from_domain
    Account.includes(:payment_processor, :users).find_by(domain: request.domain)
  end

  def account_from_subdomain
    return unless request.subdomains.size > 0
    Account.includes(:payment_processor, :users).find_by(subdomain: request.subdomains.first)
  end

  def account_from_session
    return unless user_signed_in? && (account_id = session[:account_id])
    current_user.accounts.includes(:payment_processor, :users).find_by(id: account_id)
  end

  def account_from_param
    return unless (account_id = params[:account_id].presence)
    current_user.accounts.includes(:payment_processor, :users).find_by(id: account_id)
  end

  # Returns an account sorting by personal accounts and oldest account first
  def fallback_account
    return unless user_signed_in?
    current_user.accounts.includes(:payment_processor, :users).order(created_at: :asc).first || current_user.create_default_account
  end
end
