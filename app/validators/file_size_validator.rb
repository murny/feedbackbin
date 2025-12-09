# frozen_string_literal: true

class FileSizeValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value&.attached?

    maximum = options[:maximum]

    return unless maximum && record.public_send(attribute).blob.byte_size > maximum

    record.errors.add(attribute, :file_size_too_large, maximum: ActiveSupport::NumberHelper.number_to_human_size(maximum))
  end
end
