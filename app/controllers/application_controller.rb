# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include CurrentRequest
  include CurrentTimezone
  include Pagy::Method
  include SetLocale
  include Sortable

  prepend_before_action :set_current_account
  before_action :ensure_first_run_completed

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rate_limit to: 100, within: 1.minute

  private

    # TODO: Replace with middleware that extracts account from URL slug
    def set_current_account
      Current.account ||= Account.first
    end

    def ensure_first_run_completed
      redirect_to first_run_path if Account.none?
    end
end
