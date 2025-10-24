# frozen_string_literal: true

module FeedbackbinElements
  module AlertHelper
    def render_alert(title: nil, description: nil, variant: :default, icon: nil, show_icon: true, **options, &block)
      base_classes = components_alert_base_class
      variant_classes = components_alert_variant_class(variant)
      custom_classes = options[:class]

      # Use the tw_merge helper to intelligently merge classes
      options[:class] = tw_merge(base_classes, variant_classes, custom_classes)

      # Set default icon based on variant if not specified and icons are enabled
      if show_icon && icon.nil?
        icon = components_alert_default_icon_for_variant(variant)
      elsif !show_icon
        icon = nil
      end

      # Process description from block if provided, otherwise use the description parameter
      if block_given?
        description = capture(&block)
      end

      render "feedbackbin_elements/components/alert", {
        title: title,
        description: description,
        icon: icon,
        options: options
      }
    end

    private

      def components_alert_base_class
        [
          "relative w-full rounded-lg border px-4 py-3 text-sm grid",
          "has-[>svg]:grid-cols-[calc(var(--spacing)*4)_1fr] grid-cols-[0_1fr]",
          "has-[>svg]:gap-x-3 gap-y-0.5 items-start",
          "[&>svg]:size-4 [&>svg]:translate-y-0.5 [&>svg]:text-current"
        ].join(" ")
      end

      def components_alert_variant_class(variant)
        case variant
        when :default
          "bg-card text-card-foreground"
        when :destructive
          "text-destructive bg-card [&>svg]:text-current *:data-[slot=alert-description]:text-destructive/90"
        else
          raise ArgumentError, "Unknown alert variant: #{variant}"
        end
      end

      def components_alert_default_icon_for_variant(variant)
        case variant
        when :default
          "info"
        when :destructive
          "circle-alert"
        else
          "info"
        end
      end
  end
end
