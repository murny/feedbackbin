# frozen_string_literal: true

require_relative "lib/feedbackbin_elements/version"

Gem::Specification.new do |spec|
  spec.name        = "feedbackbin_elements"
  spec.version     = FeedbackbinElements::VERSION
  spec.authors     = [ "FeedbackBin" ]
  spec.email       = [ "info@feedbackbin.com" ]
  spec.homepage    = "https://github.com/feedbackbin/feedbackbin_elements"
  spec.summary     = "Shadcn-inspired UI component library for Rails"
  spec.description = "A collection of reusable UI components built with Tailwind CSS, inspired by Shadcn UI"
  spec.license     = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.0"
  spec.add_dependency "lucide-rails"
  spec.add_dependency "tailwind_merge", "~> 1.3"
  spec.add_dependency "importmap-rails"
  spec.add_dependency "turbo-rails"
  spec.add_dependency "stimulus-rails"
  spec.add_dependency "propshaft"
  spec.add_dependency "tailwindcss-rails"
end
