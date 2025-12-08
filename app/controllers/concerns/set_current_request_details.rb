# frozen_string_literal: true

module SetCurrentRequestDetails
  extend ActiveSupport::Concern

  included do
    before_action :set_current_request_details
  end

  private

    def set_current_request_details
      Current.request_id = request.request_id
      Current.user_agent = request.user_agent
      Current.ip_address = request.remote_ip
      Current.organization = current_organization
    end

    # Override this method in subclasses if organization is determined differently
    # For now, use the simple Organization.first approach for single-tenant mode
    def current_organization
      @current_organization ||= Organization.first
    end
end
