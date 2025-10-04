# frozen_string_literal: true

module FeedbackbinElements
  module TabsHelper
    def render_tabs(items: [], index_value: 0, **options, &block)
      base_classes = components_tabs_base_class
      list_classes = components_tabs_list_class
      trigger_classes = components_tabs_trigger_class
      content_classes = components_tabs_content_class
      custom_classes = options[:class]

      # Use the tw_merge helper to intelligently merge classes
      options[:class] = tw_merge(base_classes, custom_classes)

      # Prepare the data attributes with defaults and merge with custom data
      default_data = {
        controller: "tabs",
        tabs_index_value: index_value,
        tabs_active_tab_class: "bg-background text-foreground shadow-sm dark:border-input dark:bg-input/30",
        tabs_inactive_tab_class: "text-muted-foreground hover:text-foreground hover:bg-muted/50"
      }

      # Merge any custom data attributes provided
      options[:data] = default_data.merge(options[:data] || {})

      render "feedbackbin_elements/components/tabs", {
        items: items,
        index_value: index_value,
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
