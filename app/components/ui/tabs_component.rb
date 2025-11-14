# frozen_string_literal: true

module Ui
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
          class: tw_merge("w-full", @attrs[:class]),
          data: {
            controller: "tabs",
            tabs_index_value: @index_value,
            action: "keydown.right->tabs#nextTab keydown.left->tabs#previousTab"
          }.merge(@attrs[:data] || {})
        }
      end

      def render_tab_list
        tag.div(class: list_classes, role: "tablist", aria: { orientation: "horizontal" }) do
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
            action: "click->tabs#change",
            state: index == @index_value ? "active" : "inactive"
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
          hidden: index != @index_value,
          aria: { labelledby: trigger_id(item[:value]) },
          tabindex: 0,
          data: {
            tabs_target: "panel",
            state: index == @index_value ? "active" : "inactive"
          },
          class: content_classes
        ) do
          if item[:content].present?
            item[:content]
          elsif item[:partial].present?
            render partial: item[:partial], locals: item[:locals] || {}
          end
        end
      end

      def list_classes
        [
          "inline-flex h-9 items-center justify-center rounded-lg",
          "bg-muted p-1 text-muted-foreground"
        ].join(" ")
      end

      def trigger_classes
        [
          "inline-flex items-center justify-center whitespace-nowrap rounded-md",
          "px-3 py-1 text-sm font-medium ring-offset-background transition-all",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
          "disabled:pointer-events-none disabled:opacity-50",
          # Active state (controlled by data-state attribute)
          "data-[state=active]:bg-background data-[state=active]:text-foreground data-[state=active]:shadow",
          # Icon sizing
          "[&_svg]:pointer-events-none [&_svg]:shrink-0"
        ].join(" ")
      end

      def content_classes
        "mt-2 ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
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
