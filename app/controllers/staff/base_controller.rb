# frozen_string_literal: true

module Staff
  class BaseController < ApplicationController
    layout "staff"

    before_action :ensure_staff
  end
end
