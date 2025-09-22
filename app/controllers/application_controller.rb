# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include Pagy::Backend
  include SetLocale
  include Sortable

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rate_limit to: 100, within: 1.minute

  before_action :ensure_first_run_completed

  private

    def ensure_first_run_completed
      if Organization.none?
        return if controller_name == "first_runs" # Skip for first_run controller

        redirect_to first_run_path
      end
    end
end
