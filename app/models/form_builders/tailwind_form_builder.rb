# frozen_string_literal: true

module FormBuilders
  class TailwindFormBuilder < ActionView::Helpers::FormBuilder
    TEXT_FIELD_BASE_CLASSES = "block w-full border rounded-md py-2 px-3 focus:outline-none dark:bg-gray-700/50 dark:border-gray-500 dark:text-gray-300 dark:placeholder-gray-400 dark:focus:ring-2 dark:focus:border-transparent"
    TEXT_FIELD_VALID_CLASSES = "border-gray-300 focus:ring-blue-600 focus:border-blue-600 dark:focus:ring-blue-400"
    TEXT_FIELD_INVALID_CLASSES = "pr-10 border-red-300 text-red-900 placeholder-red-300 focus:ring-red-500 focus:border-red-500"
    SELECT_BASE_CLASSES = "block w-full mt-6 sm:mt-0 border rounded-md py-2 px-3 focus:outline-none dark:bg-gray-700/50 dark:border-gray-500 dark:text-gray-300 dark:placeholder-gray-400 dark:focus:ring-2 dark:focus:border-transparent border-gray-300 focus:ring-blue-600 focus:border-blue-600 dark:focus:ring-blue-400"
    LABEL_BASE_CLASSES = "block text-sm font-medium text-gray-700 dark:text-gray-200"
    ERROR_BASE_CLASSES = "mt-2 text-sm text-red-600 dark:text-red-500"

    def text_field(attribute, options = {}, &block)
      if options[:leading_icon]
        default_opts = {class: "#{classes_for(attribute, options)} pl-10"}

        text_layout(attribute) { leading_icon(&block) + super(attribute, options.merge(default_opts)) }
      else
        default_opts = {class: classes_for(attribute, options)}

        text_layout(attribute) { super(attribute, options.merge(default_opts)) }
      end + attribute_error_message(attribute)
    end

    def email_field(attribute, options = {})
      default_opts = {class: classes_for(attribute, options)}

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def date_field(attribute, options = {})
      default_opts = {class: classes_for(attribute, options)}

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def password_field(attribute, options = {})
      default_opts = {class: classes_for(attribute, options)}

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def text_area(attribute, options = {})
      default_opts = {class: "mt-1 #{classes_for(attribute, options)}"}

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def label(attribute, text = nil, options = {}, &)
      default_opts = {class: "#{LABEL_BASE_CLASSES} #{options[:class]}"}

      super(attribute, text, options.merge(default_opts), &)
    end

    def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
      default_opts = {class: "#{options[:class]} h-4 w-4 border-gray-300 rounded"}

      super(attribute, options.merge(default_opts), checked_value, unchecked_value)
    end

    def select(attribute, choices, options = {}, html_options = {})
      default_opts = {class: "#{SELECT_BASE_CLASSES} #{html_options[:class]}"}

      super(attribute, choices, options, html_options.merge(default_opts))
    end

    private

    def classes_for(attribute, options)
      classes = if @object && @object.errors[attribute].present?
        TEXT_FIELD_BASE_CLASSES + TEXT_FIELD_INVALID_CLASSES
      else
        TEXT_FIELD_BASE_CLASSES + TEXT_FIELD_VALID_CLASSES
      end

      [classes, options[:class]].compact.join(" ")
    end

    def text_layout(attribute)
      @template.content_tag :div, class: "mt-2 relative rounded-md shadow-sm" do
        yield + attribute_error_icon(attribute)
      end
    end

    def leading_icon(&)
      @template.content_tag(:div, class: "pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3", &)
    end

    def attribute_error_icon(attribute)
      return if @object.blank? || @object.errors[attribute].blank?

      @template.content_tag :div, class: "absolute inset-y-0 right-0 pr-3 flex items-center pointer-events-none" do
        @template.inline_svg_tag(
          "icons/outline/exclaimation-circle.svg",
          class: "h-5 w-5 text-red-500",
          aria: true,
          title: "Error",
          desc: "Error icon"
        )
      end
    end

    def attribute_error_message(attribute)
      return if @object.blank? || @object.errors[attribute].blank?

      @template.content_tag :div, class: ERROR_BASE_CLASSES do
        @object.errors[attribute].first
      end
    end
  end
end
