# frozen_string_literal: true

class ResizableImageValidator < ActiveModel::EachValidator
  # Only allow resizable image formats to be uploaded such as PNG, JPEG, and GIF
  # SVGs aren't allowed because they can contain XSS attacks
  def validate_each(record, attribute, value)
    return unless value.attached?

    if ActiveStorage.variable_content_types.exclude?(value.content_type)
      record.errors.add(attribute, :image_format_not_supported)
    end
  end
end
