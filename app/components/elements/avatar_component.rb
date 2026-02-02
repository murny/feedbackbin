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
      ring: false,
      **attrs
    )
      @src = src
      @alt = alt || "Avatar"
      @size = validate_option(size, SIZES, "size")
      @shape = validate_option(shape, SHAPES, "shape")
      @fallback = generate_fallback(fallback)
      @ring = ring
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
        [
          "avatar",
          size_class,
          shape_class,
          ("avatar--ring" if @ring),
          @attrs[:class]
        ].compact.join(" ")
      end

      def size_class
        case @size
        when :sm then "avatar--sm"
        when :lg then "avatar--lg"
        when :xl then "avatar--xl"
        else nil
        end
      end

      def shape_class
        case @shape
        when :square then "avatar--square"
        else nil
        end
      end

      def generate_fallback(fallback)
        return nil if fallback.blank?

        if fallback.is_a?(String) && fallback.strip.include?(" ")
          generate_initials_from_name(fallback)
        else
          fallback
        end
      end

      def generate_initials_from_name(name)
        return "" if name.blank?

        name.strip.split.map(&:first).join("").upcase[0, 2]
      end
  end
end
