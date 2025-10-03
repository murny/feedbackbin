# frozen_string_literal: true

module FeedbackbinElements
  module AccordionHelper
    def render_accordion(items: [], **options, &block)
      base_classes = components_accordion_base_class
      item_classes = components_accordion_item_class
      trigger_classes = components_accordion_trigger_class
      content_classes = components_accordion_content_class
      custom_classes = options[:class]

      # Use the tw_merge helper to intelligently merge classes
      options[:class] = tw_merge(base_classes, custom_classes)

      render "feedbackbin_elements/components/accordion", {
        items: items,
        options: options,
        item_classes: item_classes,
        trigger_classes: trigger_classes,
        content_classes: content_classes
      }
    end

    private

      def components_accordion_base_class
        "divide-y divide-border rounded-lg shadow-sm border border-border dark:shadow-black/20"
      end

      def components_accordion_item_class
        "group"
      end

      def components_accordion_trigger_class
        [
          # Base styling
          "flex w-full cursor-pointer select-none justify-between text-left text-sm font-medium",
          "p-4 [&::-webkit-details-marker]:hidden",

          # Text color
          "text-foreground group-open:text-primary",

          # Focus
          "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:ring-[3px]",
          "focus-visible:outline-none"
        ].join(" ")
      end

      def components_accordion_content_class
        "pt-2 pb-4 px-4 text-sm"
      end
  end
end
