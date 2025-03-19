# frozen_string_literal: true

module Components
  module BreadcrumbHelper
    def render_breadcrumb(items, separator: nil, collapse: false, **options)
      breadcrumb_classes = [
        components_breadcrumb_base_class,
        options[:class]
      ].flatten.compact.join(" ")

      # Update options with the combined breadcrumb_classes
      options[:class] = breadcrumb_classes

      render "components/ui/breadcrumb", {
        items: items,
        separator: separator,
        collapse: collapse,
        options: options
      }
    end

    private

      def components_breadcrumb_base_class
        [
          "text-muted-foreground flex flex-wrap items-center gap-1.5 text-sm break-words sm:gap-2.5"
        ]
      end
  end
end
