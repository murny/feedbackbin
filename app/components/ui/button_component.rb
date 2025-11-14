# frozen_string_literal: true

module Ui
  class ButtonComponent < BaseComponent
    VARIANTS = %i[default destructive outline secondary ghost link].freeze
    SIZES = %i[default sm lg icon].freeze

    def initialize(
      variant: :default,
      size: :default,
      href: nil,
      type: :button,
      loading: false,
      **attrs
    )
      @variant = validate_option(variant, VARIANTS, "variant")
      @size = validate_option(size, SIZES, "size")
      @href = href
      @type = type
      @loading = loading
      @attrs = attrs
    end

    def call
      if @href.present?
        link_to(@href, **link_attrs) { content_with_loading }
      else
        button_tag(**button_attrs) { content_with_loading }
      end
    end

    private

      def content_with_loading
        safe_join([ loading_spinner, content ].compact)
      end

      def loading_spinner
        return unless @loading

        tag.div(class: "animate-spin mr-2", "aria-label": "Loading") do
          # Using lucide-rails icon helper
          helpers.lucide_icon("loader", class: "size-4")
        end
      end

      def link_attrs
        attrs = @attrs.merge(
          class: button_classes,
          data: @attrs[:data] || {}
        )

        # Links use aria-disabled instead of disabled attribute
        if @loading || @attrs[:disabled]
          attrs[:"aria-disabled"] = "true"
          attrs.delete(:disabled) # Remove invalid disabled attribute for links
        end

        # Add aria-busy for screen readers when loading
        attrs[:"aria-busy"] = "true" if @loading

        attrs
      end

      def button_attrs
        attrs = @attrs.merge(
          class: button_classes,
          type: @type,
          disabled: (@loading || @attrs[:disabled]),
          data: @attrs[:data] || {}
        )

        # Add aria-busy for screen readers when loading
        attrs[:"aria-busy"] = "true" if @loading

        attrs
      end

      def button_classes
        tw_merge(
          base_classes,
          variant_classes,
          size_classes,
          @attrs[:class]
        )
      end

      def base_classes
        [
          "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all shrink-0 outline-none",
          # Aria
          "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
          # Disabled (for buttons)
          "disabled:pointer-events-none disabled:opacity-50",
          # Aria-disabled (for links)
          "aria-disabled:pointer-events-none aria-disabled:opacity-50",
          # Focus
          "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
          # Icon
          "[&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 [&_svg]:shrink-0"
        ].join(" ")
      end

      def variant_classes
        case @variant
        when :default
          [
            "bg-primary text-primary-foreground shadow-xs",
            "hover:bg-primary/90"
          ].join(" ")
        when :destructive
          [
            "bg-destructive text-white shadow-xs",
            "hover:bg-destructive/90",
            "focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40",
            "dark:bg-destructive/60 dark:hover:bg-destructive/70"
          ].join(" ")
        when :outline
          [
            "border bg-background shadow-xs",
            "hover:bg-accent hover:text-accent-foreground",
            "dark:bg-input/30 dark:border-input dark:hover:bg-input/50"
          ].join(" ")
        when :secondary
          [
            "bg-secondary text-secondary-foreground shadow-xs",
            "hover:bg-secondary/80"
          ].join(" ")
        when :ghost
          [
            "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50"
          ].join(" ")
        when :link
          [
            "text-primary underline-offset-4",
            "hover:underline"
          ].join(" ")
        end
      end

      def size_classes
        case @size
        when :default
          "h-9 px-4 py-2 has-[>svg]:px-3"
        when :sm
          "h-8 rounded-md gap-1.5 px-3 has-[>svg]:px-2.5"
        when :lg
          "h-10 rounded-md px-6 has-[>svg]:px-4"
        when :icon
          "size-9"
        end
      end

      def validate_option(value, valid_options, option_name)
        return value if valid_options.include?(value)

        raise ArgumentError, "Unknown #{option_name}: #{value}. Valid options: #{valid_options.join(', ')}"
      end
  end
end
