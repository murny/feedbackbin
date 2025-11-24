# frozen_string_literal: true

module Ui
  class DropdownMenuComponent < BaseComponent
    renders_one :trigger
    renders_many :items, types: {
      content: "ItemComponent",
      separator: "SeparatorComponent",
      label: "LabelComponent"
    }

    def initialize(**attrs)
      @attrs = attrs
    end

    def call
      tag.div(**wrapper_attrs) do
        safe_join([
          trigger_wrapper,
          content_wrapper
        ])
      end
    end

    private

      def wrapper_attrs
        {
          data: {
            controller: "dropdown"
          },
          class: tw_merge("relative inline-block", @attrs[:class])
        }
      end

      def trigger_wrapper
        return unless trigger?

        tag.div(
          data: {
            dropdown_target: "trigger",
            action: "click->dropdown#toggle"
          },
          "aria-haspopup": "true",
          "aria-expanded": "false"
        ) do
          trigger.to_s
        end
      end

      def content_wrapper
        return unless items?

        tag.div(**content_attrs) do
          tag.div(class: content_inner_classes, role: "menu", "aria-orientation": "vertical") do
            safe_join(items)
          end
        end
      end

      def content_attrs
        {
          data: {
            dropdown_target: "menu",
            state: "closed"
          },
          class: content_classes
        }
      end

      def content_classes
        tw_merge(
          "absolute top-full left-0 z-50 min-w-[14rem] overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md mt-1",
          "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
          "data-[state=closed]:pointer-events-none data-[state=closed]:invisible"
        )
      end

      def content_inner_classes
        "py-1"
      end

      # Item component for menu items
      class ItemComponent < BaseComponent
        def initialize(href: nil, method: nil, params: {}, inset: false, disabled: false, id: nil, **attrs)
          @href = href
          @method = method
          @params = params
          @inset = inset
          @disabled = disabled
          @id = id
          @attrs = attrs
        end

        def call
          item_content = if @method
            # Render button_to form for POST/PATCH/DELETE actions
            button_to(@href, **form_attrs) { content }
          elsif @href
            # Render link for GET actions
            link_to(@href, **link_attrs) { content }
          else
            # Render plain button
            tag.button(**button_attrs) { content }
          end

          # Wrap in span with ID if provided (for Turbo Frame updates)
          if @id
            tag.span(id: @id) { item_content }
          else
            item_content
          end
        end

        private

          def link_attrs
            {
              class: item_classes,
              role: "menuitem",
              tabindex: @disabled ? "-1" : "0",
              "aria-disabled": @disabled ? "true" : nil,
              data: (@attrs[:data] || {}).merge(
                action: "click->dropdown#close"
              )
            }.merge(@attrs.except(:class, :data))
          end

          def button_attrs
            {
              class: item_classes,
              role: "menuitem",
              type: "button",
              disabled: @disabled,
              tabindex: @disabled ? "-1" : "0",
              data: (@attrs[:data] || {}).merge(
                action: "click->dropdown#close"
              )
            }.merge(@attrs.except(:class, :data))
          end

          def form_attrs
            {
              method: @method,
              params: @params,
              class: item_classes,
              role: "menuitem",
              data: (@attrs[:data] || {}).merge(
                action: "click->dropdown#close"
              ),
              form: {
                class: "w-full"
              }.merge(@attrs[:form] || {})
            }.merge(@attrs.except(:class, :data, :form))
          end

          def item_classes
            tw_merge(
              "relative flex w-full cursor-default select-none items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-none transition-colors",
              "hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground",
              "disabled:pointer-events-none disabled:opacity-50",
              "aria-disabled:pointer-events-none aria-disabled:opacity-50",
              "[&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
              @inset ? "pl-8" : nil,
              @attrs[:class]
            )
          end
      end

      # Separator component
      class SeparatorComponent < BaseComponent
        def call
          tag.div(class: "my-1 h-px bg-muted", role: "separator")
        end
      end

      # Label component for headers/sections
      class LabelComponent < BaseComponent
        def initialize(**attrs)
          @attrs = attrs
        end

        def call
          tag.div(class: label_classes) do
            content
          end
        end

        private

          def label_classes
            tw_merge(
              "px-2 py-1.5 text-sm font-semibold",
              @attrs[:class]
            )
          end
      end
  end
end
