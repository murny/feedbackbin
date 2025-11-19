# frozen_string_literal: true

module Ui
  class DropdownMenuComponent < BaseComponent
    ALIGNMENTS = %i[start end center].freeze
    SIDES = %i[top bottom left right].freeze

    renders_one :trigger
    renders_many :items, types: {
      item: "ItemComponent",
      separator: "SeparatorComponent",
      label: "LabelComponent",
      checkbox_item: "CheckboxItemComponent",
      radio_item: "RadioItemComponent"
    }

    def initialize(
      align: :start,
      side: :bottom,
      side_offset: 4,
      align_offset: 0,
      **attrs
    )
      @align = validate_option(align, ALIGNMENTS, "align")
      @side = validate_option(side, SIDES, "side")
      @side_offset = side_offset
      @align_offset = align_offset
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
        tag.div(
          data: {
            dropdown_target: "trigger",
            action: "click->dropdown#toggle"
          },
          role: "button",
          tabindex: "0",
          "aria-haspopup": "true",
          "aria-expanded": "false"
        ) do
          trigger
        end
      end

      def content_wrapper
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
          "absolute z-50 min-w-[8rem] overflow-hidden rounded-md border bg-popover p-1 text-popover-foreground shadow-md",
          "data-[state=open]:animate-in data-[state=closed]:animate-out data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0 data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
          "data-[state=closed]:pointer-events-none data-[state=closed]:invisible",
          position_classes
        )
      end

      def content_inner_classes
        "py-1"
      end

      def position_classes
        position = []

        # Side positioning
        case @side
        when :bottom
          position << "top-full mt-#{@side_offset}"
        when :top
          position << "bottom-full mb-#{@side_offset}"
        when :left
          position << "right-full mr-#{@side_offset}"
        when :right
          position << "left-full ml-#{@side_offset}"
        end

        # Alignment
        case @align
        when :start
          position << (@side == :bottom || @side == :top ? "left-0" : "top-0")
        when :end
          position << (@side == :bottom || @side == :top ? "right-0" : "bottom-0")
        when :center
          position << (@side == :bottom || @side == :top ? "left-1/2 -translate-x-1/2" : "top-1/2 -translate-y-1/2")
        end

        position.join(" ")
      end

      def validate_option(value, valid_options, option_name)
        return value if valid_options.include?(value)

        raise ArgumentError, "Unknown #{option_name}: #{value}. Valid options: #{valid_options.join(', ')}"
      end

      # Item component for menu items
      class ItemComponent < BaseComponent
        def initialize(href: nil, inset: false, disabled: false, **attrs)
          @href = href
          @inset = inset
          @disabled = disabled
          @attrs = attrs
        end

        def call
          if @href
            link_to(@href, **link_attrs) { content }
          else
            tag.button(**button_attrs) { content }
          end
        end

        private

          def link_attrs
            {
              class: item_classes,
              role: "menuitem",
              tabindex: @disabled ? "-1" : "0",
              "aria-disabled": @disabled ? "true" : nil,
              data: @attrs[:data] || {}
            }.merge(@attrs.except(:class, :data))
          end

          def button_attrs
            {
              class: item_classes,
              role: "menuitem",
              type: "button",
              disabled: @disabled,
              tabindex: @disabled ? "-1" : "0",
              data: @attrs[:data] || {}
            }.merge(@attrs.except(:class, :data))
          end

          def item_classes
            tw_merge(
              "relative flex cursor-default select-none items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-none transition-colors",
              "focus:bg-accent focus:text-accent-foreground",
              "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
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

      # Label component for grouping
      class LabelComponent < BaseComponent
        def initialize(inset: false, **attrs)
          @inset = inset
          @attrs = attrs
        end

        def call
          tag.div(class: label_classes) { content }
        end

        private

          def label_classes
            tw_merge(
              "px-2 py-1.5 text-sm font-semibold",
              @inset ? "pl-8" : nil,
              @attrs[:class]
            )
          end
      end

      # Checkbox item component
      class CheckboxItemComponent < BaseComponent
        def initialize(checked: false, inset: false, **attrs)
          @checked = checked
          @inset = inset
          @attrs = attrs
        end

        def call
          tag.button(**button_attrs) do
            safe_join([
              check_indicator,
              content
            ])
          end
        end

        private

          def button_attrs
            {
              class: item_classes,
              role: "menuitemcheckbox",
              type: "button",
              "aria-checked": @checked ? "true" : "false",
              data: @attrs[:data] || {}
            }.merge(@attrs.except(:class, :data))
          end

          def item_classes
            tw_merge(
              "relative flex cursor-default select-none items-center gap-2 rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none transition-colors",
              "focus:bg-accent focus:text-accent-foreground",
              "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
              @attrs[:class]
            )
          end

          def check_indicator
            tag.span(class: "absolute left-2 flex size-3.5 items-center justify-center") do
              if @checked
                helpers.lucide_icon("check", class: "size-4")
              end
            end
          end
      end

      # Radio item component
      class RadioItemComponent < BaseComponent
        def initialize(checked: false, **attrs)
          @checked = checked
          @attrs = attrs
        end

        def call
          tag.button(**button_attrs) do
            safe_join([
              radio_indicator,
              content
            ])
          end
        end

        private

          def button_attrs
            {
              class: item_classes,
              role: "menuitemradio",
              type: "button",
              "aria-checked": @checked ? "true" : "false",
              data: @attrs[:data] || {}
            }.merge(@attrs.except(:class, :data))
          end

          def item_classes
            tw_merge(
              "relative flex cursor-default select-none items-center gap-2 rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none transition-colors",
              "focus:bg-accent focus:text-accent-foreground",
              "data-[disabled]:pointer-events-none data-[disabled]:opacity-50",
              @attrs[:class]
            )
          end

          def radio_indicator
            tag.span(class: "absolute left-2 flex size-3.5 items-center justify-center") do
              if @checked
                helpers.lucide_icon("circle", class: "size-2 fill-current")
              end
            end
          end
      end
  end
end
