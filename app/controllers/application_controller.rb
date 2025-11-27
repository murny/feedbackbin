# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include Pagy::Method
  include SetLocale
  include Sortable

  before_action :ensure_first_run_completed

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rate_limit to: 100, within: 1.minute

  private

    def ensure_first_run_completed
      redirect_to first_run_path if Organization.none?
    end
end
