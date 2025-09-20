# frozen_string_literal: true

require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module FeedbackBin
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Multi-database configuration
    config.active_record.multiple_databases = true

    # Configure tenanted databases
    config.active_record.tenanted = {
      tenant_resolver: ->(request) {
        # Extract subdomain-based tenant resolution
        subdomain = request.subdomain
        return nil if subdomain.blank? || subdomain == 'www'
        
        # Check if organization exists with this subdomain
        Organization.find_by(subdomain: subdomain)&.subdomain
      },
      tenant_class: ApplicationRecord
    }

    # Add tenant selector middleware
    config.middleware.insert_before ActionDispatch::Session::CookieStore, 
      ActiveRecord::Tenanted::TenantSelector

    config.mission_control.jobs.base_controller_class = "SuperAdmin::BaseController"
    config.mission_control.jobs.http_basic_auth_enabled = false
  end
end
