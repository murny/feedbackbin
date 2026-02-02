# frozen_string_literal: true

module Elements
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
        ["breadcrumb", @attrs[:class]].compact.join(" ")
      end

      def processed_items
        return @items unless @collapse && @items.size > 3

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
