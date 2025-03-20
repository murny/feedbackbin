# frozen_string_literal: true

module Components
  module BreadcrumbHelper
    def render_breadcrumb(items, separator: nil, collapse: false, **options)
      base_classes = components_breadcrumb_base_class
      custom_classes = options[:class]

      options[:class] = tw_merge(base_classes, custom_classes)

      render "components/ui/breadcrumb", {
        items: items,
        separator: separator,
        collapse: collapse,
        options: options
      }
    end

    private

      def components_breadcrumb_base_class
        "text-muted-foreground flex flex-wrap items-center gap-1.5 text-sm break-words sm:gap-2.5"
      end
  end
end
