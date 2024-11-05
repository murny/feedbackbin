# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    skip_after_action :verify_authorized

    before_action :require_admin

    private

    def require_admin
      redirect_to root_path, alert: t("admin.base.unauthorized") unless Current.user.site_admin?
    end
  end
end
