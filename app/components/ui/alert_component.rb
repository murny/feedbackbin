# frozen_string_literal: true

module Ui
  class AlertComponent < BaseComponent
    VARIANTS = %i[default destructive].freeze

    def initialize(
      title: nil,
      description: nil,
      variant: :default,
      icon: nil,
      show_icon: true,
      **attrs
    )
      @title = title
      @description = description
      @variant = validate_option(variant, VARIANTS, "variant")
      @show_icon = show_icon
      @custom_icon = icon
      @attrs = attrs
    end

    def before_render
      # If block content is provided, use it as description
      @description = content if content.present?
    end

    def call
      tag.div(**html_attrs) do
        safe_join([
          icon_element,
          title_element,
          description_element
        ].compact)
      end
    end

    private

      def html_attrs
        @attrs.merge(
          class: alert_classes,
          role: "alert"
        )
      end

      def alert_classes
        tw_merge(
          base_classes,
          variant_classes,
          @attrs[:class]
        )
      end

      def base_classes
        [
          "relative w-full rounded-lg border px-4 py-3 text-sm grid",
          "has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr] grid-cols-[0_1fr]",
          "has-[>svg]:gap-x-3 gap-y-0.5 items-start",
          "[&>svg]:size-4 [&>svg]:translate-y-0.5 [&>svg]:text-current"
        ].join(" ")
      end

      def variant_classes
        case @variant
        when :default
          "bg-card text-card-foreground"
        when :destructive
          "text-destructive bg-card [&>svg]:text-current *:data-[slot=alert-description]:text-destructive/90"
        end
      end

      def icon_element
        return nil unless @show_icon && icon_name.present?

        helpers.lucide_icon(icon_name)
      end

      def icon_name
        return @custom_icon if @custom_icon.present?

        # Default icons based on variant
        case @variant
        when :destructive
          "circle-alert"
        else
          "info"
        end
      end

      def title_element
        return nil unless @title.present?

        tag.div(@title,
          data: { slot: "alert-title" },
          class: "col-start-2 line-clamp-1 min-h-4 font-medium tracking-tight"
        )
      end

      def description_element
        return nil unless @description.present?

        tag.div(
          data: { slot: "alert-description" },
          class: "text-muted-foreground col-start-2 grid justify-items-start gap-1 text-sm [&_p]:leading-relaxed"
        ) do
          @description
        end
      end

      def validate_option(value, valid_options, option_name)
        return value if valid_options.include?(value)

        raise ArgumentError, "Unknown #{option_name}: #{value}. Valid options: #{valid_options.join(', ')}"
      end
  end
end
