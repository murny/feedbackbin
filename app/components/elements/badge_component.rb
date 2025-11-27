# frozen_string_literal: true

module Elements
  class BadgeComponent < BaseComponent
    VARIANTS = %i[default secondary destructive outline].freeze

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
        tw_merge(
          base_classes,
          variant_classes,
          @attrs[:class]
        )
      end

      def base_classes
        [
          "inline-flex items-center justify-center rounded-md border px-2.5 py-0.5 text-xs font-semibold transition-all w-fit whitespace-nowrap shrink-0",
          # Icon support
          "[&>svg]:pointer-events-none [&>svg:not([class*='size-'])]:size-3 [&>svg:not([class*='w-'])]:w-3 [&>svg:not([class*='h-'])]:h-3",
          "[&>svg]:shrink-0",
          "gap-1",
          # Focus states
          "focus-visible:outline-hidden focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
        ].join(" ")
      end

      def variant_classes
        case @variant
        when :default
          [
            "border-transparent bg-primary text-primary-foreground shadow",
            "[a&]:hover:bg-primary/80"
          ].join(" ")
        when :secondary
          [
            "border-transparent bg-secondary text-secondary-foreground",
            "[a&]:hover:bg-secondary/80"
          ].join(" ")
        when :destructive
          [
            "border-transparent bg-destructive text-white shadow",
            "[a&]:hover:bg-destructive/80"
          ].join(" ")
        when :outline
          [
            "text-foreground",
            "[a&]:hover:bg-accent [a&]:hover:text-accent-foreground"
          ].join(" ")
        end
      end
  end
end
