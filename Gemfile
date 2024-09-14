# frozen_string_literal: true

source "https://rubygems.org"

# Rails
gem "rails", github: "rails/rails", branch: "main"

# Datastores
gem "sqlite3", ">= 2.0"

# Jobs
gem "solid_queue"
gem "mission_control-jobs"

gem "solid_cache"
gem "solid_cable"

# Deployment
gem "puma", "~> 6.4"
gem "thruster", require: false
gem "kamal", require: false

# Frontend
gem "propshaft"
gem "turbo-rails"
gem "stimulus-rails"
gem "importmap-rails"
gem "tailwindcss-rails"

gem "inline_svg"

# API
gem "jbuilder"

gem "pagy", "~> 9.0"

gem "bcrypt", "~> 3.1.7"

gem "tzinfo-data", platforms: %i[windows jruby]

gem "bootsnap", require: false

gem "image_processing", ">= 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"

  gem "i18n-tasks", require: false

  # Linters
  gem "erb_lint", require: false
  gem "erblint-github", require: false
  gem "rubocop", require: false
  gem "rubocop-capybara", require: false
  gem "rubocop-minitest", require: false
  gem "rubocop-performance", require: false
  gem "rubocop-rails", require: false
  gem "standard", require: false

  # Security checks
  gem "brakeman", require: false
  gem "bundler-audit", require: false
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  gem "letter_opener_web", "~> 3.0"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end
