# frozen_string_literal: true

module Components
  module ToastHelper
    def render_toast(title: nil, description: nil, variant: :default, icon: nil, show_icon: true, dismiss_after: 3000, dismissable: true, action: nil, **options)
      base_classes = components_toast_base_class
      variant_classes = components_toast_variant_class(variant)
      animation_classes = components_toast_animation_class
      custom_classes = options[:class]

      # Use the tw_merge helper to intelligently merge classes
      inner_classes = tw_merge(base_classes, variant_classes, animation_classes)

      # Set default icon based on variant if not specified and icons are enabled
      if show_icon && icon.nil?
        icon = components_toast_default_icon_for_variant(variant)
      elsif !show_icon
        icon = nil
      end

      # Add data attributes for alert behavior
      options[:data] ||= {}
      options[:data][:controller] = "alert"

      # Only add dismiss_after value if it's not false
      if dismiss_after != false
        options[:data][:alert_dismiss_after_value] = dismiss_after
      end

      render "components/ui/toast", {
        title: title,
        description: description,
        icon: icon,
        action: action,
        dismissable: dismissable,
        options: options.merge(class: custom_classes),
        inner_classes: inner_classes
      }
    end

    private

      def components_toast_base_class
        [
          "pointer-events-auto w-full max-w-sm overflow-hidden rounded-md bg-white",
          "shadow-lg ring-1 ring-black ring-opacity-5 dark:bg-neutral-950",
          "dark:border dark:border-neutral-700/80 transform transition-all duration-300"
        ].join(" ")
      end

    def components_toast_variant_class(variant)
      case variant
      when :default
        "text-foreground"
      when :success
        "border-l-4 border-l-success"
      when :warning
        "border-l-4 border-l-warning"
      when :error
        "border-l-4 border-l-destructive"
      when :info
        "border-l-4 border-l-primary"
      else
        raise ArgumentError, "Unknown toast variant: #{variant}"
      end
    end

    def components_toast_animation_class
      "animate-in fade-in slide-in-from-right"
    end

    def components_toast_default_icon_for_variant(variant)
      case variant
      when :default
        "icons/info.svg"
      when :success
        "icons/circle-check.svg"
      when :warning
        "icons/triangle-alert.svg"
      when :error
        "icons/circle-alert.svg"
      when :info
        "icons/info.svg"
      else
        "icons/info.svg"
      end
    end
  end
end
