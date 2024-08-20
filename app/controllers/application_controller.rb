# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Authentication
  include Pagy::Backend
  include Sortable

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  rate_limit to: 100, within: 1.minute
end
