# frozen_string_literal: true

module SetCurrentOrganization
  extend ActiveSupport::Concern

  included do
    before_action :set_current_organization
  end

  private

    def set_current_organization
      Current.organization ||= organization_from_subdomain
    end

    def organization_from_subdomain
      return nil if ApplicationRecord.current_tenant.blank?
      Organization.find_by(subdomain: ApplicationRecord.current_tenant)
    end
end
