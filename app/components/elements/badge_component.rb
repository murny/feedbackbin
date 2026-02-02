# frozen_string_literal: true

module Elements
  class BadgeComponent < BaseComponent
    VARIANTS = %i[default primary secondary destructive outline success warning].freeze

    def initialize(
      variant: :default,
      href: nil,
      **attrs
    )
      @variant = validate_option(variant, VARIANTS, "variant")
      @href = href
      @attrs = attrs
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
        @attrs.merge(
          class: badge_classes,
          data: @attrs[:data] || {}
        )
      end

      def badge_classes
        [
          "badge",
          variant_class,
          @attrs[:class]
        ].compact.join(" ")
      end

      def variant_class
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
