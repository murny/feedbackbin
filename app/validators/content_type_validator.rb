# frozen_string_literal: true

class ContentTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value&.attached?

    allowed_types = options[:in] || []

    unless allowed_types.include?(value.content_type)
      record.errors.add(attribute, :invalid_content_type)
    end
  end
end
