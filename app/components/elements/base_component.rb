# frozen_string_literal: true

module Elements
  class BaseComponent < ViewComponent::Base
    private

      # Validates that a value is in the list of valid options
      # Raises ArgumentError with helpful message if invalid
      def validate_option(value, valid_options, option_name)
        return value if valid_options.include?(value)

        raise ArgumentError, "Unknown #{option_name}: #{value}. Valid options: #{valid_options.join(', ')}"
      end
  end
end
