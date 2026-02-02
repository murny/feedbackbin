# frozen_string_literal: true

module Elements
  class AlertComponent < BaseComponent
    VARIANTS = %i[default destructive success warning info].freeze

    def initialize(
      title: nil,
      description: nil,
      variant: :default,
      icon: nil,
      show_icon: true,
      **attrs
    )
      @title = title
      @description = description
      @variant = validate_option(variant, VARIANTS, "variant")
      @show_icon = show_icon
      @custom_icon = icon
      @attrs = attrs
    end

    def before_render
      @description = content if content.present?
    end

    def call
      tag.div(**html_attrs) do
        safe_join([
          icon_element,
          title_element,
          description_element
        ].compact)
      end
    end

    private

      def html_attrs
        @attrs.merge(
          class: alert_classes,
          role: "alert"
        )
      end

      def alert_classes
        [
          "alert",
          variant_class,
          @attrs[:class]
        ].compact.join(" ")
      end

      def variant_class
        case @variant
        when :default then nil
        when :destructive then "alert--destructive"
        when :success then "alert--success"
        when :warning then "alert--warning"
        when :info then "alert--info"
        end
      end

      def icon_element
        return nil unless @show_icon && icon_name.present?

        helpers.lucide_icon(icon_name)
      end

      def icon_name
        return @custom_icon if @custom_icon.present?

        case @variant
        when :destructive then "circle-alert"
        when :success then "circle-check"
        when :warning then "triangle-alert"
        when :info then "info"
        else "info"
        end
      end

      def title_element
        return nil unless @title.present?

        tag.h2(@title, class: "alert__title", data: { slot: "alert-title" })
      end

      def description_element
        return nil unless @description.present?

        tag.section(class: "alert__description", data: { slot: "alert-description" }) do
          @description
        end
      end
  end
end
