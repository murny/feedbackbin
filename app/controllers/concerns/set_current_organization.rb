# frozen_string_literal: true

module SetCurrentOrganization
  extend ActiveSupport::Concern

  included do
    before_action :set_current_organization
  end

  private

  def set_current_organization
    Current.organization ||= organization_from_domain || organization_from_subdomain || organization_from_param || organization_from_session || fallback_organization
  end

  def organization_from_domain
    Organization.includes(:users).find_by(domain: request.host)
  end

  def organization_from_subdomain
    return unless request.subdomains.size > 0
    Organization.includes(:users).find_by(subdomain: request.subdomains.first)
  end

  def organization_from_param
    return unless (organization_id = params[:organization_id].presence)
    Current.user.organizations.includes(:users).find_by(id: organization_id)
  end

  def organization_from_session
    return unless authenticated? && (organization_id = session[:organization_id])
    Current.user.organizations.includes(:users).find_by(id: organization_id)
  end

  def fallback_organization
    return unless authenticated?
    Current.user.organizations.includes(:users).order(created_at: :asc).first
  end
end
