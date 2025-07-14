# frozen_string_literal: true

module FormBuilders
  class CustomFormBuilder < ActionView::Helpers::FormBuilder
    INPUT_VALID_CLASSES = "border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 " \
    "flex w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] " \
    "outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 dark:bg-input/30 md:text-sm"

    INPUT_INVALID_CLASSES = "border-input placeholder:text-muted-foreground focus-visible:border-ring focus-visible:ring-ring/50 " \
    "aria-invalid:ring-destructive/20 dark:aria-invalid:ring-destructive/40 aria-invalid:border-destructive " \
    "flex w-full rounded-md border bg-transparent px-3 py-2 text-base shadow-xs transition-[color,box-shadow] " \
    "outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 dark:bg-input/30 md:text-sm"

    SELECT_CLASSES = "border-input data-[placeholder]:text-muted-foreground [&_svg:not([class*='text-'])]:text-muted-foreground " \
    "focus-visible:border-ring focus-visible:ring-ring/50 flex w-full items-center justify-between gap-2 " \
    "rounded-md border bg-transparent px-3 py-2 text-sm whitespace-nowrap shadow-xs transition-[color,box-shadow] " \
    "outline-none focus-visible:ring-[3px] disabled:cursor-not-allowed disabled:opacity-50 " \
    "dark:bg-input/30 dark:hover:bg-input/50 h-9"

    LABEL_VALID_CLASSES = "flex items-center gap-2 text-sm leading-none font-medium select-none " \
    "group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 " \
    "peer-disabled:cursor-not-allowed peer-disabled:opacity-50"
    LABEL_INVALID_CLASSES = "flex items-center gap-2 text-sm leading-none font-medium select-none " \
    "group-data-[disabled=true]:pointer-events-none group-data-[disabled=true]:opacity-50 " \
    "peer-disabled:cursor-not-allowed peer-disabled:opacity-50 text-destructive"

    ERROR_MESSAGE_CLASSES = "text-destructive text-sm"

    CHECKBOX_CLASSES = "h-4 w-4 rounded border-input bg-background text-primary focus-visible:ring-2 " \
    "focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"

    SUBMIT_CLASSES = "btn-primary"

    def text_field(attribute, options = {}, &block)
      if options[:leading_icon]
        default_opts = { class: "#{classes_for_input(attribute, options)} pl-10" }

        text_layout(attribute) { leading_icon(&block) + super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
      else
        default_opts = { class: classes_for_input(attribute, options) }

        text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
      end
    end

    def email_field(attribute, options = {})
      default_opts = { class: classes_for_input(attribute, options) }

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def date_field(attribute, options = {})
      default_opts = { class: classes_for_input(attribute, options) }

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def password_field(attribute, options = {})
      default_opts = { class: classes_for_input(attribute, options) }

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def text_area(attribute, options = {})
      # Use existing input classes and add textarea-specific classes
      base_classes = classes_for_input(attribute, options)
      textarea_specific_classes = "field-sizing-content min-h-16 resize-none"

      default_opts = { class: [ base_classes, textarea_specific_classes, options[:class] ].compact.join(" ") }

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def rich_text_area(attribute, options = {})
      default_opts = { class: "mt-1 #{classes_for_input(attribute, options)}" }

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def label(attribute, text = nil, options = {}, &)
      default_opts = { class: classes_for_label(attribute, options) }

      super(attribute, text, options.merge(default_opts), &)
    end

    def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
      default_opts = { class: [ CHECKBOX_CLASSES, options[:class] ].compact.join(" ") }

      super(attribute, options.merge(default_opts), checked_value, unchecked_value)
    end

    # TODO: Style select/check box?/time_zone_select with error styles
    def select(attribute, choices, options = {}, html_options = {})
      default_opts = { class: [ SELECT_CLASSES, html_options[:class] ].compact.join(" ") }

      super(attribute, choices, options, html_options.merge(default_opts)) + attribute_error_message(attribute)
    end

    def time_zone_select(attribute, priority_zones = nil, options = {}, html_options = {})
      default_opts = { class: [ SELECT_CLASSES, html_options[:class] ].compact.join(" ") }

      super(attribute, priority_zones, options, html_options.merge(default_opts)) + attribute_error_message(attribute)
    end

    def submit(value = nil, options = {})
      default_opts = { class: [ SUBMIT_CLASSES, options[:class] ].compact.join(" ") }

      super(value, options.merge(default_opts))
    end

    private

      def classes_for_input(attribute, options)
        classes = if @object && @object.errors[attribute].present?
          INPUT_INVALID_CLASSES
        else
          INPUT_VALID_CLASSES
        end

        [ classes, options[:class] ].compact.join(" ")
      end

    def classes_for_label(attribute, options)
      classes = if @object && @object.errors[attribute].present?
        LABEL_INVALID_CLASSES
      else
        LABEL_VALID_CLASSES
      end

      [ classes, options[:class] ].compact.join(" ")
    end

    def text_layout(attribute)
      @template.content_tag :div, class: "relative grid gap-2", "data-slot": "form-item" do
        yield + attribute_error_icon(attribute)
      end
    end

    def leading_icon(&)
      @template.content_tag(:div, class: "pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3", &)
    end

    def attribute_error_icon(attribute)
      return if @object.blank? || @object.errors[attribute].blank?

      @template.content_tag :div, class: "pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3 " do
        @template.inline_svg_tag(
          "icons/circle-alert.svg",
          class: "h-5 w-5 text-red-500",
          aria: true,
          title: "Error",
          desc: "Error icon"
        )
      end
    end

    def attribute_error_message(attribute)
      return if @object.blank? || @object.errors[attribute].blank?

      @template.content_tag :div, class: ERROR_MESSAGE_CLASSES do
        @object.errors[attribute].to_sentence.upcase_first
      end
    end
  end
end
