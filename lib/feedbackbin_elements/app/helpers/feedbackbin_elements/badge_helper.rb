# frozen_string_literal: true

module FeedbackbinElements
  module BadgeHelper
    def render_badge(text: nil, variant: :default, href: nil, data: {}, **options, &block)
      base_classes = components_badge_base_class
      variant_classes = components_badge_variant_class(variant)
      custom_classes = options[:class]

      # Use the tw_merge helper to intelligently merge classes
      options[:class] = tw_merge(base_classes, variant_classes, custom_classes)

      if block_given?
        text = capture(&block)
      end

      render "feedbackbin_elements/components/badge", {
        text: text,
        href: href,
        data: data,
        options: options
      }
    end

    private

      def components_badge_base_class
        [
          "inline-flex items-center justify-center rounded-md border px-2 py-0.5 text-xs font-medium w-fit whitespace-nowrap shrink-0",
          "[&>svg]:size-3 gap-1 [&>svg]:pointer-events-none",
          "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
          "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive",
          "transition-[color,box-shadow] overflow-hidden"
        ].join(" ")
      end

      def components_badge_variant_class(variant)
        case variant
        when :default
          [
            "border-transparent bg-primary text-primary-foreground",
            "[a&]:hover:bg-primary/90"
          ].join(" ")
        when :secondary
          [
            "border-transparent bg-secondary text-secondary-foreground",
            "[a&]:hover:bg-secondary/90"
          ].join(" ")
        when :destructive
          [
            "border-transparent bg-destructive text-white",
            "[a&]:hover:bg-destructive/90",
            "focus-visible:ring-destructive/20 dark:focus-visible:ring-destructive/40",
            "dark:bg-destructive/70"
          ].join(" ")
        when :outline
          [
            "text-foreground",
            "[a&]:hover:bg-accent [a&]:hover:text-accent-foreground"
          ].join(" ")
        else
          raise ArgumentError, "Unknown badge variant: #{variant}"
        end
      end
  end
end
