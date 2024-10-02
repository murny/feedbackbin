# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :require_admin

    private

    def require_admin
      redirect_to root_path, alert: t("admin.base.unauthorized") unless Current.user.can_administer?
    end
  end
end
