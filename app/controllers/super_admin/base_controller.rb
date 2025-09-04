# frozen_string_literal: true

module SuperAdmin
  class BaseController < ApplicationController
    layout "super_admin"

    skip_after_action :verify_authorized

    before_action :require_super_admin

    private

      def require_super_admin
        redirect_to root_path, alert: t("super_admin.base.unauthorized") unless Current.user.super_admin?
      end
  end
end
