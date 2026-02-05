# frozen_string_literal: true

module Elements
  class DropdownMenuComponent < BaseComponent
    renders_one :trigger, lambda { |variant: :outline, size: :default, **attrs, &block|
      @trigger_variant = variant
      @trigger_size = size
      @trigger_attrs = attrs
      @trigger_block = block
    }

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
        data = (@attrs[:data] || {}).dup
        data[:controller] = [ data[:controller], "dropdown" ].compact.join(" ")

        {
          data: data,
          class: tw_merge("relative inline-block", @attrs[:class])
        }.merge(@attrs.except(:class, :data))
      end

      def trigger_wrapper
        return unless trigger?

        # Merge Stimulus and ARIA attributes into the trigger attrs
        attrs = @trigger_attrs || {}
        trigger_data = (attrs[:data] || {}).merge(
          dropdown_target: "trigger",
          action: "click->dropdown#toggle"
        )

        trigger_aria = (attrs[:aria] || {}).merge(
          haspopup: "true",
          expanded: "false"
        )

        # Render ButtonComponent with all attributes
        render Elements::ButtonComponent.new(
          variant: @trigger_variant || :outline,
          size: @trigger_size || :default,
          data: trigger_data,
          aria: trigger_aria,
          **attrs.except(:data, :aria)
        ) do
          capture(&@trigger_block) if @trigger_block
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
          # Normalize :get to nil - GET requests should be links, not forms
          @method = method == :get ? nil : method
          @params = params
          @inset = inset
          @disabled = disabled
          @id = id
          @attrs = attrs
        end

        def call
          item_content = if @disabled
            # Render non-interactive span for disabled items
            tag.span(**disabled_attrs) { content }
          elsif @method
            # Render form with properly attributed button for POST/PATCH/DELETE actions
            # Manual form construction for full control over button attributes
            tag.form(**form_wrapper_attrs) do
              safe_join([
                form_hidden_fields,
                tag.button(**form_button_attrs) { content }
              ])
            end
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

          def disabled_attrs
            {
              class: item_classes,
              role: "menuitem",
              "aria-disabled": "true",
              data: (@attrs[:data] || {}).merge(disabled: "true")
            }.merge(@attrs.except(:class, :data))
          end

          def link_attrs
            {
              class: item_classes,
              role: "menuitem",
              tabindex: "0",
              data: (@attrs[:data] || {}).merge(
                action: combined_action
              )
            }.merge(@attrs.except(:class, :data))
          end

          def button_attrs
            {
              class: item_classes,
              role: "menuitem",
              type: "button",
              tabindex: "0",
              data: (@attrs[:data] || {}).merge(
                action: combined_action
              )
            }.merge(@attrs.except(:class, :data))
          end

          def form_hidden_fields
            safe_join([
              csrf_token_tag,
              method_override_tag,
              params_tags
            ].compact)
          end

          def csrf_token_tag
            helpers.hidden_field_tag(
              :authenticity_token,
              helpers.form_authenticity_token,
              autocomplete: "off"
            )
          end

          def method_override_tag
            return unless @method && ![ :get, :post ].include?(@method)

            helpers.hidden_field_tag(:_method, @method, autocomplete: "off")
          end

          def params_tags
            return if @params.empty?

            @params.map do |key, value|
              helpers.hidden_field_tag(key, value, autocomplete: "off")
            end
          end

          def form_wrapper_attrs
            {
              action: @href,
              method: :post,
              class: "w-full",
              data: {
                turbo_confirm: @attrs.dig(:form, :data, :turbo_confirm)
              }.compact
            }
          end

          def form_button_attrs
            {
              type: "submit",
              class: item_classes,
              role: "menuitem",
              tabindex: "0",
              data: (@attrs[:data] || {}).merge(
                action: combined_action
              )
            }.merge(@attrs.except(:class, :data, :form))
          end

          def item_classes
            tw_merge(
              "relative flex w-full cursor-default select-none items-center gap-2 rounded-sm px-2 py-1.5 text-sm outline-hidden transition-colors",
              "hover:bg-accent hover:text-accent-foreground focus:bg-accent focus:text-accent-foreground",
              "disabled:pointer-events-none disabled:opacity-50",
              "aria-disabled:pointer-events-none aria-disabled:opacity-50",
              "[&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0",
              @inset ? "pl-8" : nil,
              @attrs[:class]
            )
          end

          def combined_action
            existing_action = (@attrs[:data] || {})[:action]
            [ existing_action, "click->dropdown#close" ].compact.join(" ")
          end
      end

      # Separator component
      class SeparatorComponent < BaseComponent
        def call
          tag.div(class: "my-1 h-px bg-border", role: "separator")
        end
      end

      # Label component for headers/sections
      class LabelComponent < BaseComponent
        def initialize(**attrs)
          @attrs = attrs
        end

        def call
          tag.div(**label_attrs) do
            content
          end
        end

        private

          def label_attrs
            { class: label_classes }.merge(@attrs.except(:class))
          end

          def label_classes
            tw_merge(
              "px-2 py-1.5 text-sm font-semibold",
              @attrs[:class]
            )
          end
      end
  end
end
