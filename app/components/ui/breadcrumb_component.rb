# frozen_string_literal: true

module Ui
  class BreadcrumbComponent < BaseComponent
    def initialize(items:, separator: nil, collapse: false, **attrs)
      @items = items
      @separator = separator
      @collapse = collapse
      @attrs = attrs
    end

    private

      def html_attrs
        {
          class: breadcrumb_classes,
          data: { slot: "breadcrumb" },
          aria: { label: "breadcrumb" }
        }
      end

      def breadcrumb_classes
        tw_merge(base_classes, @attrs[:class])
      end

      def base_classes
        "text-muted-foreground flex flex-wrap items-center gap-1.5 text-sm break-words sm:gap-2.5"
      end

      def processed_items
        return @items unless @collapse && @items.size > 3

        # Collapse to: first ... last
        [
          @items.first,
          { is_ellipsis: true },
          @items.last
        ]
      end

      def separator_content
        return @separator if @separator.present?

        helpers.lucide_icon("chevron-right")
      end

      def last_item?(index)
        index == processed_items.size - 1
      end
  end
end
