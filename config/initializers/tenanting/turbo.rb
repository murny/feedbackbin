# frozen_string_literal: true

# Patches Turbo::StreamsChannel to include account slug in rendered URLs
# This ensures background job broadcasts use correct account-scoped URLs
module TurboStreamsJobExtensions
  extend ActiveSupport::Concern

  class_methods do
    def render_format(format, **rendering)
      if Current.account.present?
        ApplicationController.renderer.new(script_name: Current.account.slug).render(formats: [ format ], **rendering)
      else
        super
      end
    end
  end
end

Rails.application.config.after_initialize do
  Turbo::StreamsChannel.prepend TurboStreamsJobExtensions
end
