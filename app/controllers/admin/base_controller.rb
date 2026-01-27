# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    layout "admin"
    skip_after_action :verify_authorized

    before_action :ensure_admin
  end
end
