# frozen_string_literal: true

SimpleCov.start :rails do
  formatter SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::JSONFormatter
  ])

  enable_coverage :branch

  group "Policies", "app/policies"
end
