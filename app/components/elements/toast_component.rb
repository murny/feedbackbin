# frozen_string_literal: true

module Elements
  class ToastComponent < BaseComponent
    VARIANTS = %i[default success warning error info].freeze

    def initialize(
      title: nil,
      description: nil,
      variant: :default,
      icon: nil,
      show_icon: true,
      dismiss_after: 5000,
      dismissable: true,
      action_label: nil,
      action_href: nil,
      **attrs
    )
      @title = title
      @description = description
      @variant = validate_option(variant, VARIANTS, "variant")
      @show_icon = show_icon
      @custom_icon = icon
      @dismiss_after = dismiss_after
      @dismissable = dismissable
      @action_label = action_label
      @action_href = action_href
      @attrs = attrs
    end

    def before_render
      @description = content if content.present?
    end

    def call
      tag.div(**html_attrs) do
        safe_join([
          icon_element,
          content_wrapper,
          action_element,
          dismiss_button
        ].compact)
      end
    end

    private

      def html_attrs
        data_attrs = {
          controller: "toast",
          action: "mouseenter->toast#pause mouseleave->toast#resume"
        }

        data_attrs[:toast_dismiss_after_value] = @dismiss_after if @dismiss_after && @dismiss_after > 0
        data_attrs = data_attrs.merge(@attrs[:data] || {})

        aria_live = @variant == :error ? "assertive" : "polite"

        @attrs.merge(
          class: toast_classes,
          role: "status",
          "aria-live": aria_live,
          "aria-atomic": "true",
          data: data_attrs
        )
      end

      def toast_classes
        [
          "toast",
          variant_class,
          @attrs[:class]
        ].compact.join(" ")
      end

      def variant_class
        case @variant
        when :success then "toast--success"
        when :warning then "toast--warning"
        when :error then "toast--error"
        when :info then "toast--info"
        else nil
        end
      end

      def icon_element
        return nil unless @show_icon && icon_name.present?

        helpers.lucide_icon(icon_name)
      end

      def icon_name
        return @custom_icon if @custom_icon.present?

        case @variant
        when :success then "circle-check"
        when :warning then "triangle-alert"
        when :error then "circle-alert"
        when :info then "info"
        else nil
        end
      end

      def content_wrapper
        tag.div(class: "toast__content") do
          safe_join([
            title_element,
            description_element
          ].compact)
        end
      end

      def title_element
        return nil unless @title.present?

        tag.h2(@title, class: "toast__title")
      end

      def description_element
        return nil unless @description.present?

        tag.p(@description, class: "toast__description")
      end

      def action_element
        return nil unless @action_label.present? && @action_href.present?

        tag.div(class: "toast__action") do
          helpers.link_to(@action_label, @action_href, class: "toast__action-button")
        end
      end

      def dismiss_button
        return nil unless @dismissable

        tag.button(
          type: "button",
          class: "toast__dismiss",
          "aria-label": t("ui.toast.dismiss"),
          data: { action: "toast#close" }
        ) do
          helpers.lucide_icon("x")
        end
      end
  end
end
