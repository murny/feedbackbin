# frozen_string_literal: true

module Components
  module BreadcrumbHelper
    def render_breadcrumb(items, separator: nil, collapse: false, **options)
      base_classes = components_breadcrumb_base_class
      custom_classes = options[:class]

      options[:class] = tw_merge(base_classes, custom_classes)

      # Process the items to handle collapse logic
      processed_items = process_breadcrumb_items(items, collapse)

      render "components/ui/breadcrumb", {
        items: processed_items,
        separator: separator,
        collapse: collapse,
        options: options
      }
    end

    # Helper method that can be called from the view
    def breadcrumb_separator(separator = nil)
      separator.present? ? separator : inline_svg_tag("icons/chevron-right.svg")
    end

    private

      def components_breadcrumb_base_class
        "text-muted-foreground flex flex-wrap items-center gap-1.5 text-sm break-words sm:gap-2.5"
      end

      def process_breadcrumb_items(items, collapse)
        return items unless collapse && items.size > 3

        # Keep first, last, and a placeholder for ellipsis
        [
          items.first,
          { is_ellipsis: true },
          items.last
        ]
      end
  end
end
