# frozen_string_literal: true

module Components
  module ButtonHelper
    VARIANTS = %i[default primary secondary destructive outline ghost]

    def render_button(label = "", text: nil, variant: :default, size: :md, icon: nil, icon_right: nil, as: nil, href: nil, data: {}, **options, &block)
      # Determine if we're using a link or button
      as = href.present? ? :link : :button unless as

      # Build the button classes
      button_classes = [
        base_class,
        variant_class(variant),
        size_class(size, icon.present? && !icon_right.present? && !text.present? && !block_given?),
        options[:class]
      ].flatten.compact.join(" ")

      # Determine content - prioritize block over parameters
      if block_given?
        content = capture(&block)
      else
        content = build_content_with_icons(text || label, icon, icon_right)
      end

      # Render the partial
      render "components/ui/button", {
        content: content,
        href: href,
        button_classes: button_classes,
        as: as,
        data: data,
        options: options
      }
    end

    private

      def build_content_with_icons(text, icon, icon_right)
        result = ActiveSupport::SafeBuffer.new

        # If no text and only left icon, return just the icon
        if text.blank? && icon.present? && icon_right.blank?
          return inline_svg_tag("icons/#{icon}.svg")
        end

        # Otherwise build the content with icons and text
        if icon.present?
          result << inline_svg_tag("icons/#{icon}.svg", class: "mr-2")
        end

        result << text if text.present?

        if icon_right.present?
          result << inline_svg_tag("icons/#{icon_right}.svg", class: "ml-2")
        end

        result
      end

    def base_class
      [
        "inline-flex items-center cursor-pointer shrink-0 justify-center rounded-md border gap-2 font-medium select-none",
        # Disabled
        "disabled:opacity-70 disabled:pointer-events-none",
        # Focus
        "focus-visible:outline-none focus-visible:ring-[3px] focus-visible:ring-offset-2 focus-visible:ring-ring ring-offset-background",
        # Icon
        "[&_svg]:pointer-events-none [&_svg]:shrink-0"
      ]
    end

    def variant_class(variant)
      case variant
      when :default
        [
          "bg-background text-foreground border-border",
          "hover:bg-zinc-50 dark:hover:bg-zinc-900"
        ]
      when :primary
        [
          "bg-primary text-primary-foreground border-primary",
          "hover:bg-primary/90 dark:hover:bg-primary/90"
        ]
      when :secondary
        [
          "bg-secondary text-secondary-foreground border-secondary",
          "hover:bg-secondary/90 dark:hover:bg-secondary/90"
        ]
      when :destructive
        [
          "bg-destructive text-destructive-foreground border-destructive",
          "hover:bg-destructive/90 dark:hover:bg-destructive/90",
          "disabled:text-destructive-foreground/80"
        ]
      when :outline
        [
          "bg-background text-foreground border-input",
          "hover:bg-accent hover:text-accent-foreground"
        ]
      when :ghost
        [
          "bg-transparent text-foreground border-transparent",
          "hover:bg-zinc-200/50 dark:hover:bg-zinc-900",
          "disabled:text-muted-foreground"
        ]
      else
        raise ArgumentError, "Unknown variant `#{variant}'"
      end
    end

    def size_class(size, icon_only = false)
      base_classes = case size
      when :xs
        "px-1.5 h-6 text-xs"
      when :sm
        "px-2.5 h-7 text-sm"
      when :md
        "px-4 h-10 text-base"
      when :lg
        "px-5 h-11 text-lg"
      else
        raise ArgumentError, "Unknown size `#{size}'"
      end

      # For icon-only buttons, make them square by adjusting padding
      if icon_only
        case size
        when :sm
          base_classes += " px-0 w-7"
        when :md
          base_classes += " px-0 w-10"
        when :lg
          base_classes += " px-0 w-11"
        when :xs
          base_classes += " px-0 w-6"
        end
      end

      base_classes
    end
  end
end
