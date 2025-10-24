# frozen_string_literal: true

module FeedbackbinElements
  module ButtonHelper
    def render_button(text: nil, variant: :default, size: :default, href: nil, type: :button, loading: false, data: {}, **options, &block)
      base_classes = components_button_base_class
      variant_classes = components_button_variant_class(variant)
      size_classes = components_button_size_class(size)
      custom_classes = options[:class]

      # Use the tw_merge helper to intelligently merge classes
      options[:class] = tw_merge(base_classes, variant_classes, size_classes, custom_classes)
      options[:type] = type unless href.present?
      options[:disabled] = true if loading

      if block_given?
        text = capture(&block)
      end

      render "feedbackbin_elements/components/button", {
        text: text,
        href: href,
        loading: loading,
        data: data,
        options: options
      }
    end

    private

      def components_button_base_class
        [
          "inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-all shrink-0 outline-none",
          # Aria
          "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
          # Disabled
          "disabled:pointer-events-none disabled:opacity-50",
          # Focus
          "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
          # Icon
          "[&_svg]:pointer-events-none [&_svg:not([class*='size-'])]:size-4 [&_svg]:shrink-0"
        ].join(" ")
      end

      def components_button_variant_class(variant)
        case variant
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
            "dark:bg-destructive/60"
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
        else
          raise ArgumentError, "Unknown button variant: #{variant}"
        end
      end

      def components_button_size_class(size)
        case size
        when :default
          "h-9 px-4 py-2 has-[>svg]:px-3"
        when :sm
          "h-8 rounded-md gap-1.5 px-3 has-[>svg]:px-2.5"
        when :lg
          "h-10 rounded-md px-6 has-[>svg]:px-4"
        when :icon
          "size-9"
        else
          raise ArgumentError, "Unknown button size: #{size}"
        end
      end
  end
end
