# frozen_string_literal: true

class ContentTypeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.attached?

    allowed_types = Array(options[:in] || options[:with])
    return if allowed_types.empty?

    unless allowed_types.include?(value.content_type)
      record.errors.add(attribute, :invalid_content_type)
    end
  end
end
