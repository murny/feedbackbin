# frozen_string_literal: true

module SetCurrentOrganization
  extend ActiveSupport::Concern

  included do
    before_action :set_current_organization
  end

  private

    def set_current_organization
      Current.organization ||= organization_from_subdomain || fallback_organization
    end

  def organization_from_subdomain
    return unless request.subdomains.size > 0
    Organization.includes(:users).find_by(subdomain: request.subdomains.first)
  end

  def fallback_organization
    # TODO: this needs to be removed!
    #
    # TODO: We need to revisit this and ensure this logic is correct for multi vs single tenant mode
    if authenticated?
      organization = Current.user.organizations.includes(:users).order(created_at: :asc).first
    end

    if organization.nil?
      # TODO: How to handle this for unauthenticated users? In multi tenant mode, should redirect to marketing site?
      organization = Organization.includes(:users).order(created_at: :asc).first
    end

    organization
  end
end
