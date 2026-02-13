# frozen_string_literal: true

module FormBuilders
  class CustomFormBuilder < ActionView::Helpers::FormBuilder
    INPUT_VALID_CLASSES = ""
    INPUT_INVALID_CLASSES = ""
    SELECT_CLASSES = ""
    LABEL_VALID_CLASSES = ""
    LABEL_INVALID_CLASSES = "txt-negative"
    ERROR_MESSAGE_CLASSES = "txt-negative txt-small"
    CHECKBOX_CLASSES = ""
    SUBMIT_CLASSES = "btn btn--primary"

    def text_field(attribute, options = {}, &block)
      if options[:leading_icon]
        default_opts = { class: classes_for_input(attribute, options), style: "padding-inline-start: 2.5rem;" }

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

    def url_field(attribute, options = {})
      default_opts = { class: classes_for_input(attribute, options) }

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def text_area(attribute, options = {})
      default_opts = { class: classes_for_input(attribute, options) }

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def rich_text_area(attribute, options = {})
      default_opts = { class: [ "lexxy-content", options[:class] ].compact_blank.join(" ") }

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def label(attribute, text = nil, options = {}, &)
      default_opts = { class: classes_for_label(attribute, options) }

      super(attribute, text, options.merge(default_opts), &)
    end

    def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
      default_opts = { class: [ CHECKBOX_CLASSES, options[:class] ].compact_blank.join(" ") }

      super(attribute, options.merge(default_opts), checked_value, unchecked_value)
    end

    # TODO: Style select/check box?/time_zone_select with error styles
    def select(attribute, choices, options = {}, html_options = {})
      default_opts = { class: [ SELECT_CLASSES, html_options[:class] ].compact_blank.join(" ") }

      super(attribute, choices, options, html_options.merge(default_opts)) + attribute_error_message(attribute)
    end

    def time_zone_select(attribute, priority_zones = nil, options = {}, html_options = {})
      default_opts = { class: [ SELECT_CLASSES, html_options[:class] ].compact_blank.join(" ") }

      super(attribute, priority_zones, options, html_options.merge(default_opts)) + attribute_error_message(attribute)
    end

    def submit(value = nil, options = {})
      default_opts = { class: [ SUBMIT_CLASSES, options[:class] ].compact_blank.join(" ") }

      super(value, options.merge(default_opts))
    end

    private

      def classes_for_input(attribute, options)
        classes = if @object && @object.errors[attribute].present?
          INPUT_INVALID_CLASSES
        else
          INPUT_VALID_CLASSES
        end

        [ classes, options[:class] ].compact_blank.join(" ")
      end

      def classes_for_label(attribute, options)
        classes = if @object && @object.errors[attribute].present?
          LABEL_INVALID_CLASSES
        else
          LABEL_VALID_CLASSES
        end

        [ classes, options[:class] ].compact_blank.join(" ")
      end

      def text_layout(attribute)
        @template.content_tag :div, class: "position-relative grid gap-half", "data-slot": "form-item" do
          yield + attribute_error_icon(attribute)
        end
      end

      def leading_icon(&)
        @template.content_tag(:div, class: "flex align-center", style: "pointer-events: none; position: absolute; inset-block: 0; inset-inline-start: 0; padding-inline-start: 0.75rem;", &)
      end

      def attribute_error_icon(attribute)
        return if @object.blank? || @object.errors[attribute].blank?

        @template.content_tag :div, class: "flex align-center", style: "pointer-events: none; position: absolute; inset-block: 0; inset-inline-end: 0; padding-inline-end: 0.75rem;" do
          @template.lucide_icon(
            "circle-alert",
            class: "size-5 txt-negative",
            "aria-hidden": true,
            focusable: false
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
