# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    layout "admin"

    before_action :ensure_admin
  end
end
