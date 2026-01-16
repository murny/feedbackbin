# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include CurrentRequest, CurrentTimezone
  include Pagy::Method
  include SetLocale
  include Sortable

  before_action :ensure_signup_completed

  stale_when_importmap_changes
  allow_browser versions: :modern
  rate_limit to: 100, within: 1.minute

  private

    def ensure_signup_completed
      redirect_to signup_path if Account.none?
    end
end
