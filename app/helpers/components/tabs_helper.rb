# frozen_string_literal: true

module Components
  module TabsHelper
    def render_tabs(items: [], default_value: nil, **options, &block)
      base_classes = components_tabs_base_class
      list_classes = components_tabs_list_class
      trigger_classes = components_tabs_trigger_class
      content_classes = components_tabs_content_class
      custom_classes = options[:class]

      # Use the tw_merge helper to intelligently merge classes
      options[:class] = tw_merge(base_classes, custom_classes)

      # Default to first tab if not specified
      default_value ||= items.first&.dig(:value)

      render "components/ui/tabs", {
        items: items,
        default_value: default_value,
        options: options,
        list_classes: list_classes,
        trigger_classes: trigger_classes,
        content_classes: content_classes
      }
    end

    private

      def components_tabs_base_class
        "flex flex-col gap-2"
      end

      def components_tabs_list_class
        "bg-muted text-muted-foreground inline-flex h-9 w-fit items-center justify-center rounded-lg p-[3px]"
      end

      def components_tabs_trigger_class
        [
          # Base styling
          "inline-flex h-[calc(100%-1px)] flex-1 items-center justify-center gap-1.5",
          "rounded-md border border-transparent px-3 py-1 text-sm font-medium whitespace-nowrap",
          "transition-all duration-200 ease-in-out",

          # Focus
          "focus:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
          "disabled:pointer-events-none disabled:opacity-50",

          # Icon styling
          "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
        ].join(" ")
      end

      def components_tabs_content_class
        "flex-1 outline-none mt-2"
      end
  end
end
