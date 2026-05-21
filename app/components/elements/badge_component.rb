# frozen_string_literal: true

module Elements
  class BadgeComponent < BaseComponent
    VARIANTS = %i[default primary secondary destructive outline success warning].freeze
    TONES    = %i[solid soft].freeze

    def initialize(
      variant: nil,
      color: nil,
      tone: nil,
      with_dot: false,
      href: nil,
      **attrs
    )
      if color && variant
        raise ArgumentError, "BadgeComponent: pass variant: (semantic) OR color: (runtime), not both"
      end
      if tone && !color
        raise ArgumentError, "BadgeComponent: tone: is only valid with color:"
      end

      @color    = color
      @tone     = tone || (color ? :solid : nil)
      @variant  = variant || (color ? nil : :default)
      @with_dot = with_dot
      @href     = href
      @attrs    = attrs

      validate_option(@variant, VARIANTS, "variant") if @variant
      validate_option(@tone,    TONES,    "tone")    if @tone
    end

    def call
      if @href.present?
        link_to(@href, **badge_attrs) { badge_content }
      else
        tag.span(**badge_attrs) { badge_content }
      end
    end

    private

      def badge_content
        raise ArgumentError, "Badge content cannot be empty" if content.blank?

        content
      end

      def badge_attrs
        attrs = @attrs.merge(class: badge_classes, data: @attrs[:data] || {})
        return attrs unless @color

        style = [ "--badge-color-source: #{@color};", @attrs[:style] ].compact.join(" ")
        attrs.merge(style: style)
      end

      def badge_classes
        [
          "badge",
          variant_class,
          ("badge--with-dot" if @with_dot),
          @attrs[:class]
        ].compact.join(" ")
      end

      def variant_class
        return "badge--#{@tone}" if @tone

        case @variant
        when :default, :primary then "badge--primary"
        when :secondary then "badge--secondary"
        when :outline then "badge--outline"
        when :destructive then "badge--destructive"
        when :success then "badge--success"
        when :warning then "badge--warning"
        end
      end
  end
end
