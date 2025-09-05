# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :require_admin

    private

      def require_admin
        authorize :admin, :access?
      end
  end
end
