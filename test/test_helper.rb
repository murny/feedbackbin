# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "simplecov" if ENV["COVERAGE"]

require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"
require "webmock/minitest"

# Allow localhost connections for system tests (Selenium/Capybara)
WebMock.disable_net_connect!(allow_localhost: true)

# Load support files
Dir[Rails.root.join("test/support/**/*.rb")].each { |f| require f }

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    if ENV["COVERAGE"]
      parallelize_setup do |worker|
        SimpleCov.command_name "#{SimpleCov.command_name}-#{worker}"
      end

      parallelize_teardown do
        SimpleCov.result
      end
    end

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    include SessionTestHelper

    setup do
      Current.account = accounts(:feedbackbin)
    end

    teardown do
      Current.clear_all
    end

    # Helper to get the script_name for current account
    def account_script_name
      Current.account&.slug || ""
    end
  end
end

class ActionDispatch::IntegrationTest
  # Set up integration session with account script_name for URL generation and routing
  setup do
    if Current.account.present?
      integration_session.default_url_options[:script_name] = Current.account.slug
    end
  end

  # Helper for making requests without account scope (for disallow_account_scope controllers)
  def untenanted
    original_script_name = integration_session.default_url_options[:script_name]
    original_account = Current.account
    integration_session.default_url_options[:script_name] = ""
    Current.account = nil
    yield
  ensure
    integration_session.default_url_options[:script_name] = original_script_name
    Current.account = original_account
  end

  # Helper for making requests with a specific account context
  def tenanted(account)
    original_script_name = integration_session.default_url_options[:script_name]
    original_account = Current.account
    integration_session.default_url_options[:script_name] = account.slug
    Current.account = account
    yield
  ensure
    integration_session.default_url_options[:script_name] = original_script_name
    Current.account = original_account
  end
end

class ActionView::TestCase
  # Set up controller default_url_options with account script_name for helper tests
  setup do
    if Current.account.present?
      @controller.class.default_url_options[:script_name] = Current.account.slug
    end
  end

  teardown do
    @controller.class.default_url_options.delete(:script_name)
  end
end
