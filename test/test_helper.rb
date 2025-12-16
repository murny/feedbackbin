# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"

require "simplecov" if ENV["COVERAGE"]

require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

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
  end
end
