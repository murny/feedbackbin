# frozen_string_literal: true

module Components
  module ButtonHelper
    def render_button(text: nil, variant: :default, size: :default, href: nil, type: :button, loading: false, data: {}, **options, &block)
      button_classes = [
        components_button_base_class,
        components_button_variant_class(variant),
        components_button_size_class(size),
        options[:class]
      ].flatten.compact.join(" ")

      # Update options with the combined button_classes
      options[:class] = button_classes
      options[:type] = type unless href.present?
      options[:disabled] = true if loading

      if block_given?
        text = capture(&block)
      end

      render "components/ui/button", {
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
        ]
      end

    def components_button_variant_class(variant)
      case variant
      when :default
        [
          "bg-primary text-primary-foreground shadow-xs",
          "hover:bg-primary/90"
        ]
      when :destructive
        [
          "bg-destructive text-white shadow-xs",
           "hover:bg-destructive/90",
          "focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40",
          "dark:bg-destructive/60"
        ]
      when :outline
        [
          "border bg-background shadow-xs",
          "hover:bg-accent hover:text-accent-foreground",
          "dark:bg-input/30 dark:border-input dark:hover:bg-input/50"
        ]
      when :secondary
        [
          "bg-secondary text-secondary-foreground shadow-xs",
          "hover:bg-secondary/80"
        ]
      when :ghost
        [
          "hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50"
        ]
      when :link
        [
          "text-primary underline-offset-4",
          "hover:underline"
        ]
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
