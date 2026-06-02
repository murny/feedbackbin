# frozen_string_literal: true

Rails.application.config.to_prepare do
  default_attributes = ActionText::ContentHelper.sanitizer.class.allowed_attributes
  ActionText::ContentHelper.allowed_attributes =
    (default_attributes + ActionText::Attachment::ATTRIBUTES + %w[data-turbo-frame]).to_set
end
