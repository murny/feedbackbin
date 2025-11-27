# frozen_string_literal: true

module Elements
  class TabsComponent < BaseComponent
    def initialize(items:, index_value: 0, **attrs)
      @items = items
      @index_value = index_value
      @attrs = attrs
    end

    def call
      tag.div(**container_attrs) do
        safe_join([
          render_tab_list,
          render_tab_panels
        ])
      end
    end

    private

      def container_attrs
        {
          class: tw_merge("flex flex-col gap-2 w-full", @attrs[:class]),
          data: {
            controller: "tabs",
            tabs_index_value: @index_value,
            action: "keydown.right->tabs#nextTab keydown.left->tabs#previousTab keydown.home->tabs#firstTab keydown.end->tabs#lastTab"
          }.merge(@attrs[:data] || {})
        }
      end

      def render_tab_list
        tag.div(
          role: "tablist",
          aria: { orientation: "horizontal" },
          class: "bg-muted text-muted-foreground inline-flex h-9 w-fit items-center justify-center rounded-lg p-[3px]"
        ) do
          safe_join(
            @items.map.with_index do |item, index|
              render_tab_trigger(item, index)
            end
          )
        end
      end

      def render_tab_trigger(item, index)
        tag.button(
          type: "button",
          id: trigger_id(item[:value]),
          disabled: item[:disabled],
          role: "tab",
          aria: {
            selected: (index == @index_value).to_s,
            controls: panel_id(item[:value])
          },
          data: {
            tabs_target: "tab",
            action: "click->tabs#change"
          },
          class: trigger_classes
        ) do
          safe_join([
            (lucide_icon(item[:icon], class: "size-4") if item[:icon].present?),
            item[:label]
          ].compact)
        end
      end

      def render_tab_panels
        safe_join(
          @items.map.with_index do |item, index|
            render_tab_panel(item, index)
          end
        )
      end

      def render_tab_panel(item, index)
        tag.div(
          id: panel_id(item[:value]),
          role: "tabpanel",
          aria: { labelledby: trigger_id(item[:value]) },
          tabindex: 0,
          data: {
            tabs_target: "panel"
          },
          class: panel_classes(index)
        ) do
          if item[:content].present?
            item[:content]
          elsif item[:partial].present?
            render partial: item[:partial], locals: item[:locals] || {}
          end
        end
      end

      def trigger_classes
        [
          # Base styles
          "focus-visible:border-ring focus-visible:ring-ring/50 focus-visible:outline-ring",
          "text-foreground dark:text-muted-foreground",
          "inline-flex h-[calc(100%_-_1px)] flex-1 items-center justify-center gap-1.5",
          "rounded-md border border-transparent px-2 py-1 text-sm font-medium whitespace-nowrap",
          "transition-[color,box-shadow]",
          "focus-visible:ring-[3px] focus-visible:outline-1",
          "disabled:pointer-events-none disabled:opacity-50",
          # Active state (when aria-selected="true")
          "aria-selected:bg-background aria-selected:dark:text-foreground aria-selected:dark:border-input aria-selected:dark:bg-input/30 aria-selected:shadow-sm",
          # Icon styles
          "[&_svg]:pointer-events-none [&_svg]:shrink-0 [&_svg:not([class*='size-'])]:size-4"
        ].join(" ")
      end

      def panel_classes(index)
        classes = [ "flex-1 outline-hidden" ]
        classes << "hidden" if index != @index_value
        classes.join(" ")
      end

      def trigger_id(value)
        "tab-#{value}"
      end

      def panel_id(value)
        "panel-#{value}"
      end

      def lucide_icon(name, **options)
        helpers.lucide_icon(name, **options)
      end
  end
end
