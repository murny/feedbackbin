# frozen_string_literal: true

module Elements
  class TabsComponent < BaseComponent
    VARIANTS = %i[default underline pills].freeze

    def initialize(items:, index_value: 0, variant: :default, **attrs)
      @items = items
      @index_value = index_value
      @variant = variant
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
          class: container_classes,
          data: {
            controller: "tabs",
            tabs_index_value: @index_value,
            action: "keydown.right->tabs#nextTab keydown.left->tabs#previousTab keydown.home->tabs#firstTab keydown.end->tabs#lastTab"
          }.merge(@attrs[:data] || {})
        }
      end

      def container_classes
        [
          "tabs",
          variant_class,
          @attrs[:class]
        ].compact.join(" ")
      end

      def variant_class
        case @variant
        when :underline then "tabs--underline"
        when :pills then "tabs--pills"
        else nil
        end
      end

      def render_tab_list
        tag.div(
          role: "tablist",
          aria: { orientation: "horizontal" },
          class: "tabs__list"
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
          class: "tabs__trigger"
        ) do
          safe_join([
            (lucide_icon(item[:icon]) if item[:icon].present?),
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

      def panel_classes(index)
        [
          "tabs__panel",
          ("hidden" if index != @index_value)
        ].compact.join(" ")
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
