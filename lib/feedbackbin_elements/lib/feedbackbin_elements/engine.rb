# frozen_string_literal: true

require "importmap-rails"
require "turbo-rails"
require "stimulus-rails"
require "tailwindcss-rails"
require "tailwind_merge"

module FeedbackbinElements
  class Engine < ::Rails::Engine
    isolate_namespace FeedbackbinElements

    initializer "feedbackbin_elements.assets" do |app|
      app.config.assets.paths << root.join("app/assets/tailwind")
      app.config.assets.paths << root.join("app/javascript")
    end

    initializer "feedbackbin_elements.importmap", after: "importmap" do |app|
      FeedbackbinElements.importmap.draw(root.join("config/importmap.rb"))

      if app.config.importmap.sweep_cache && app.config.reloading_enabled?
        FeedbackbinElements.importmap.cache_sweeper(watches: root.join("app/javascript"))

        ActiveSupport.on_load(:action_controller_base) do
          before_action { FeedbackbinElements.importmap.cache_sweeper.execute_if_updated }
        end
      end
    end

    initializer "feedbackbin_elements.helpers" do
      config.to_prepare do
        # Include all FeedbackbinElements helper modules into ActionView
        ActionView::Base.class_eval do
          include FeedbackbinElements::TailwindMergeHelper
          include FeedbackbinElements::AccordionHelper
          include FeedbackbinElements::AlertHelper
          include FeedbackbinElements::AvatarHelper
          include FeedbackbinElements::BadgeHelper
          include FeedbackbinElements::BreadcrumbHelper
          include FeedbackbinElements::ButtonHelper
          include FeedbackbinElements::CardHelper
          include FeedbackbinElements::DropdownMenuHelper
          include FeedbackbinElements::FormHelper
          include FeedbackbinElements::PopoverHelper
          include FeedbackbinElements::TabsHelper
          include FeedbackbinElements::ToastHelper
        end
      end
    end
  end
end
