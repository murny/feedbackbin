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
          class: [ "dropdown", @attrs[:class] ].compact.join(" ")
        }.merge(@attrs.except(:class, :data))
      end

      def trigger_wrapper
        return unless trigger?

        attrs = @trigger_attrs || {}
        trigger_data = (attrs[:data] || {}).merge(
          dropdown_target: "trigger",
          action: "click->dropdown#toggle"
        )

        trigger_aria = (attrs[:aria] || {}).merge(
          haspopup: "true",
          expanded: "false"
        )

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
          tag.div(class: "py-1", role: "menu", "aria-orientation": "vertical") do
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
          class: "dropdown__menu"
        }
      end

      # Item component for menu items
      class ItemComponent < BaseComponent
        def initialize(href: nil, method: nil, params: {}, inset: false, disabled: false, id: nil, **attrs)
          @href = href
          @method = method == :get ? nil : method
          @params = params
          @inset = inset
          @disabled = disabled
          @id = id
          @attrs = attrs
        end

        def call
          item_content = if @disabled
            tag.span(**disabled_attrs) { content }
          elsif @method
            tag.form(**form_wrapper_attrs) do
              safe_join([
                form_hidden_fields,
                tag.button(**form_button_attrs) { content }
              ])
            end
          elsif @href
            link_to(@href, **link_attrs) { content }
          else
            tag.button(**button_attrs) { content }
          end

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
            [
              "dropdown__item",
              ("dropdown__item--inset" if @inset),
              @attrs[:class]
            ].compact.join(" ")
          end

          def combined_action
            existing_action = (@attrs[:data] || {})[:action]
            [ existing_action, "click->dropdown#close" ].compact.join(" ")
          end
      end

      # Separator component
      class SeparatorComponent < BaseComponent
        def call
          tag.div(class: "dropdown__separator", role: "separator")
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
            { class: [ "dropdown__label", @attrs[:class] ].compact.join(" ") }.merge(@attrs.except(:class))
          end
      end
  end
end
