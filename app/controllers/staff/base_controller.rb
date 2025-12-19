# frozen_string_literal: true

module Staff
  class BaseController < ApplicationController
    layout "staff"

    skip_after_action :verify_authorized

    before_action :require_staff

    private

      def require_staff
        redirect_to root_path, alert: t("staff.base.unauthorized") unless Current.identity.staff?
      end
  end
end
