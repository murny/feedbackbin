# frozen_string_literal: true

class UrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank? && options[:allow_blank]
    return if value.present? && valid_relative_path?(value) && options[:allow_relative]
    return if value.present? && valid_absolute_url?(value)

    record.errors.add(attribute, options[:message] || :invalid_url)
  end

  private

    def valid_relative_path?(value)
      value.start_with?("/") && !value.include?("//")
    end

    def valid_absolute_url?(value)
      uri = URI.parse(value)
      (uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)) && uri.scheme.present? && uri.host.present?
    rescue URI::InvalidURIError
      false
    end
end
