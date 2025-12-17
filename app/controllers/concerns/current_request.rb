# frozen_string_literal: true

module CurrentRequest
  extend ActiveSupport::Concern

  included do
    before_action :set_current_request_details
  end

  private

    def set_current_request_details
      Current.http_method = request.method
      Current.request_id  = request.uuid
      Current.user_agent  = request.user_agent
      Current.ip_address  = request.ip
      Current.referrer    = request.referrer
    end
end
