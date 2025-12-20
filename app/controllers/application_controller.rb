# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include Authorization
  include CurrentRequest
  include CurrentTimezone
  include Pagy::Method
  include SetLocale
  include Sortable

  before_action :require_account
  before_action :ensure_first_run_completed

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  rate_limit to: 100, within: 1.minute

  class << self
    # Skip account requirement for controllers/actions that work without account scope
    # Used for auth pages (sign_in, sign_up, etc.) that should work globally
    def disallow_account_scope(**options)
      skip_before_action :require_account, **options
      before_action :ensure_no_account_scope, **options
    end
  end

  private

    # Require an account to be set in Current.account
    # Redirects to account selection if no account in URL
    def require_account
      return if Current.account.present?

      redirect_to_account_selection
    end

    def redirect_to_account_selection
      # For authenticated users, redirect to their first accessible account
      if Current.identity.present?
        user = Current.identity.users.active.first
        if user
          redirect_to root_url(script_name: user.account.slug), allow_other_host: true
          return
        end
      end

      # No account available - redirect to sign in
      redirect_to sign_in_path(script_name: nil), allow_other_host: true
    end

    def ensure_no_account_scope
      return unless Current.account.present?

      # If we're on a route that disallows account scope but have an account,
      # redirect to the non-scoped version
      redirect_to url_for(script_name: nil), allow_other_host: true
    end

    def ensure_first_run_completed
      redirect_to first_run_path if Account.none?
    end
end
