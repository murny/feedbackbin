# frozen_string_literal: true

module Ui
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
      # If block content is provided, use it as description
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
          toast_dismiss_after_value: @dismiss_after,
          action: "toast:close->toast#close"
        }.merge(@attrs[:data] || {})

        @attrs.merge(
          class: toast_classes,
          role: "status",
          "aria-live": "polite",
          "aria-atomic": "true",
          data: data_attrs
        )
      end

      def toast_classes
        tw_merge(
          base_classes,
          variant_classes,
          @attrs[:class]
        )
      end

      def base_classes
        [
          "group pointer-events-auto relative flex w-full items-start gap-3 overflow-hidden",
          "rounded-lg border p-4 shadow-lg transition-all",
          "data-[state=open]:animate-in data-[state=closed]:animate-out",
          "data-[state=closed]:fade-out-80 data-[state=open]:fade-in-0",
          "data-[state=closed]:slide-out-to-right-full data-[state=open]:slide-in-from-top-full",
          "[&>svg]:size-5 [&>svg]:shrink-0"
        ].join(" ")
      end

      def variant_classes
        case @variant
        when :default
          "bg-card text-card-foreground border-l-4 border-l-border"
        when :success
          "bg-card text-card-foreground border-l-4 border-l-green-500 [&>svg]:text-green-500"
        when :warning
          "bg-card text-card-foreground border-l-4 border-l-yellow-500 [&>svg]:text-yellow-500"
        when :error
          "bg-card text-card-foreground border-l-4 border-l-destructive [&>svg]:text-destructive"
        when :info
          "bg-card text-card-foreground border-l-4 border-l-primary [&>svg]:text-primary"
        end
      end

      def icon_element
        return nil unless @show_icon && icon_name.present?

        helpers.lucide_icon(icon_name)
      end

      def icon_name
        return @custom_icon if @custom_icon.present?

        # Default icons based on variant
        case @variant
        when :success
          "circle-check"
        when :warning
          "triangle-alert"
        when :error
          "circle-alert"
        when :info
          "info"
        else
          "info"
        end
      end

      def content_wrapper
        tag.div(class: "flex-1 grid gap-1") do
          safe_join([
            title_element,
            description_element
          ].compact)
        end
      end

      def title_element
        return nil unless @title.present?

        tag.div(@title,
          class: "text-sm font-semibold [&+div]:text-xs"
        )
      end

      def description_element
        return nil unless @description.present?

        tag.div(@description,
          class: "text-sm text-muted-foreground opacity-90"
        )
      end

      def action_element
        return nil unless @action_label.present? && @action_href.present?

        tag.div(class: "flex items-center shrink-0") do
          helpers.link_to(
            @action_label,
            @action_href,
            class: "inline-flex h-8 shrink-0 items-center justify-center rounded-md border bg-transparent px-3 text-sm font-medium transition-colors hover:bg-secondary focus:outline-none focus:ring-1 focus:ring-ring"
          )
        end
      end

      def dismiss_button
        return nil unless @dismissable

        tag.button(
          type: "button",
          class: "absolute right-1 top-1 rounded-md p-1 text-muted-foreground/50 opacity-0 transition-opacity hover:text-muted-foreground focus:opacity-100 focus:outline-none focus:ring-1 group-hover:opacity-100",
          "aria-label": "Close",
          data: { action: "toast#close" }
        ) do
          helpers.lucide_icon("x", class: "size-4")
        end
      end
  end
end
