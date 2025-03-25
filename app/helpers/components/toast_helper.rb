# frozen_string_literal: true

module Components
  module ToastHelper
    def render_toast(title: nil, description: nil, variant: :default, icon: nil, show_icon: true, duration: 3000, position: :bottom_right, action: nil, dismiss: true, **options, &block)
      base_classes = components_toast_base_class
      variant_classes = components_toast_variant_class(variant)
      position_classes = components_toast_position_class(position)
      custom_classes = options[:class]

      # Use the tw_merge helper to intelligently merge classes
      options[:class] = tw_merge(base_classes, variant_classes, position_classes, custom_classes)

      # Set default icon based on variant if not specified and icons are enabled
      if show_icon && icon.nil?
        icon = default_icon_for_variant(variant)
      elsif !show_icon
        icon = nil
      end

      # Process description from block if provided, otherwise use the description parameter
      if block_given?
        description = capture(&block)
      end

      # Add data attributes
      options[:data] ||= {}
      options[:data][:controller] ||= "ui--toast"
      options[:data][:ui__toast_target] = "item"
      options[:data][:duration] = duration if duration.present?

      render "components/ui/toast", {
        title: title,
        description: description,
        icon: icon,
        action: action,
        dismiss: dismiss,
        options: options
      }
    end

    def render_toast_container(position: :bottom_right, auto_show: false, limit: nil, **options)
      base_classes = "fixed pointer-events-none z-50"
      position_classes = components_toast_container_position_class(position)
      custom_classes = options[:class]

      # Use the tw_merge helper to intelligently merge classes
      options[:class] = tw_merge(base_classes, position_classes, custom_classes)

      # Add data attributes
      options[:data] ||= {}
      options[:data][:controller] ||= "ui--toast"
      options[:data][:auto] = "false" unless auto_show
      options[:data][:ui__toast_limit_value] = limit if limit.present?

      # Set role for accessibility
      options[:role] = "region"
      options[:aria] = { live: "assertive" }

      tag.div(**options) { yield if block_given? }
    end

    private

      def components_toast_base_class
        [
          "pointer-events-auto w-full max-w-sm overflow-hidden rounded-md bg-white",
          "shadow-lg ring-1 ring-black ring-opacity-5 dark:bg-neutral-950",
          "dark:border dark:border-neutral-700/80 transform transition-all duration-300",
          "data-[state=open]:animate-in data-[state=closed]:animate-out",
          "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0"
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

    def components_toast_position_class(position)
      case position
      when :bottom_right
        "data-[state=open]:slide-in-from-right-full data-[state=closed]:slide-out-to-right-full"
      when :bottom_left
        "data-[state=open]:slide-in-from-left-full data-[state=closed]:slide-out-to-left-full"
      when :top_right
        "data-[state=open]:slide-in-from-right-full data-[state=closed]:slide-out-to-right-full"
      when :top_left
        "data-[state=open]:slide-in-from-left-full data-[state=closed]:slide-out-to-left-full"
      when :top_center
        "data-[state=open]:slide-in-from-top-full data-[state=closed]:slide-out-to-top-full"
      when :bottom_center
        "data-[state=open]:slide-in-from-bottom-full data-[state=closed]:slide-out-to-bottom-full"
      else
        raise ArgumentError, "Unknown toast position: #{position}"
      end
    end

    def components_toast_container_position_class(position)
      case position
      when :bottom_right
        "bottom-0 right-0 flex flex-col items-end gap-2 pr-4 pb-4 sm:pr-6 sm:pb-6"
      when :bottom_left
        "bottom-0 left-0 flex flex-col items-start gap-2 pl-4 pb-4 sm:pl-6 sm:pb-6"
      when :top_right
        "top-0 right-0 flex flex-col items-end gap-2 pr-4 pt-4 sm:pr-6 sm:pt-6"
      when :top_left
        "top-0 left-0 flex flex-col items-start gap-2 pl-4 pt-4 sm:pl-6 sm:pt-6"
      when :top_center
        "top-0 inset-x-0 flex flex-col items-center gap-2 pt-4 sm:pt-6"
      when :bottom_center
        "bottom-0 inset-x-0 flex flex-col items-center gap-2 pb-4 sm:pb-6"
      else
        raise ArgumentError, "Unknown toast container position: #{position}"
      end
    end

    def default_icon_for_variant(variant)
      case variant
      when :default
        "icons/info.svg"
      when :success
        "icons/circle-check.svg"
      when :warning
        "icons/circle-alert.svg"
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
