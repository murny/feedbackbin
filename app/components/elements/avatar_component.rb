# frozen_string_literal: true

module Elements
  class AvatarComponent < BaseComponent
    SIZES = %i[sm default lg xl].freeze
    SHAPES = %i[circle square].freeze

    def initialize(
      src: nil,
      alt: nil,
      size: :default,
      shape: :circle,
      fallback: nil,
      **attrs
    )
      @src = src
      @alt = alt || "Avatar"
      @size = validate_option(size, SIZES, "size")
      @shape = validate_option(shape, SHAPES, "shape")
      @fallback = generate_fallback(fallback)
      @attrs = attrs
    end

    private

      def html_attrs
        @attrs.merge(
          class: avatar_classes,
          data: { slot: "avatar" }.merge(@attrs[:data] || {})
        )
      end

      def avatar_classes
        tw_merge(base_classes, size_classes, shape_classes, @attrs[:class])
      end

      def base_classes
        [
          "relative flex shrink-0 overflow-hidden",
          # Focus
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        ].join(" ")
      end

      def size_classes
        case @size
        when :sm
          "size-6" # 24px
        when :default
          "size-8" # 32px
        when :lg
          "size-12" # 48px
        when :xl
          "size-16" # 64px
        end
      end

      def shape_classes
        case @shape
        when :circle
          "rounded-full"
        when :square
          "rounded-md"
        end
      end

      def generate_fallback(fallback)
        return nil if fallback.blank?

        # If fallback contains space, assume it's a full name and generate initials
        if fallback.is_a?(String) && fallback.strip.include?(" ")
          generate_initials_from_name(fallback)
        else
          fallback
        end
      end

      def generate_initials_from_name(name)
        return "" if name.blank?

        # Take first letter of each word, uppercase, limit to 2 characters
        name.strip.split.map(&:first).join("").upcase[0, 2]
      end

      def validate_option(value, valid_options, option_name)
        return value if valid_options.include?(value)

        raise ArgumentError, "Unknown #{option_name}: #{value}. Valid options: #{valid_options.join(', ')}"
      end
  end
end
