# frozen_string_literal: true

module Elements
  class ButtonComponent < BaseComponent
    VARIANTS = %i[default primary destructive outline secondary ghost link].freeze
    SIZES = %i[default sm lg icon].freeze

    def initialize(
      variant: :default,
      size: :default,
      href: nil,
      type: :button,
      method: nil,
      loading: false,
      **attrs
    )
      @variant = validate_option(variant, VARIANTS, "variant")
      @size = validate_option(size, SIZES, "size")
      @href = href
      @type = type
      @method = method
      @loading = loading
      @attrs = attrs
    end

    def call
      if @href.present? && @method.present?
        button_to(@href, **button_to_attrs) { content }
      elsif @href.present?
        link_to(@href, **link_attrs) { content }
      else
        button_tag(**button_attrs) { content }
      end
    end

    private

      def link_attrs
        attrs = @attrs.merge(
          class: button_classes,
          data: @attrs[:data] || {}
        )

        if @loading || @attrs[:disabled]
          attrs[:"aria-disabled"] = "true"
          attrs.delete(:disabled)
        end

        attrs[:"aria-busy"] = "true" if @loading

        attrs
      end

      def button_attrs
        attrs = @attrs.merge(
          class: button_classes,
          type: @type,
          disabled: (@loading || @attrs[:disabled]),
          data: @attrs[:data] || {}
        )

        attrs[:"aria-busy"] = "true" if @loading

        attrs
      end

      def button_to_attrs
        attrs = @attrs.merge(
          method: @method,
          class: button_to_classes,
          data: @attrs[:data] || {}
        )

        attrs[:disabled] = true if @loading || @attrs[:disabled]
        attrs[:"aria-busy"] = "true" if @loading

        attrs
      end

      def button_to_classes
        class_names(
          button_classes,
          "btn-to"
        )
      end

      def button_classes
        class_names(
          "btn",
          variant_class,
          size_class,
          ("btn--loading" if @loading),
          @attrs[:class]
        )
      end

      def variant_class
        case @variant
        when :default, :primary then "btn--primary"
        when :secondary then "btn--secondary"
        when :outline then "btn--outline"
        when :ghost then "btn--ghost"
        when :link then "btn--link"
        when :destructive then "btn--destructive"
        end
      end

      def size_class
        case @size
        when :default then nil
        when :sm then "btn--sm"
        when :lg then "btn--lg"
        when :icon then "btn--icon"
        end
      end
  end
end
