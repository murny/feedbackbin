# frozen_string_literal: true

require "simplecov_json_formatter"

SimpleCov.start :rails do
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter
  ])

  enable_coverage :branch

  add_group "Policies", "app/policies"
end
