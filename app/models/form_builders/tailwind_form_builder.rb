# frozen_string_literal: true

module FormBuilders
  class TailwindFormBuilder < ActionView::Helpers::FormBuilder
    INPUT_VALID_CLASSES = "block w-full rounded-md border-0 py-1.5 shadow-sm sm:text-sm sm:leading-6 " \
    "ring-1 ring-inset focus:ring-2 focus:ring-inset focus:ring-blue-600 dark:focus:ring-blue-500 " \
    "dark:bg-white/5 text-gray-900 dark:text-white ring-gray-300 dark:ring-white/10 " \
    "placeholder:text-gray-400 dark:placeholder:text-gray-500"

    INPUT_INVALID_CLASSES = "block w-full rounded-md py-1.5 shadow-sm sm:text-sm sm:leading-6 " \
    "border border-red-500 dark:border-red-500 bg-red-50 dark:bg-gray-700 text-red-900 dark:text-red-500 " \
    "focus:ring-red-500  focus:border-red-500 placeholder-red-700 dark:placeholder-red-500"

    SELECT_CLASSES = "block w-full mt-6 sm:mt-0 border rounded-md py-2 px-3 focus:outline-none " \
    "dark:bg-gray-700/50 dark:border-gray-500 dark:text-gray-300 dark:placeholder-gray-400 dark:focus:ring-2 " \
    "dark:focus:border-transparent border-gray-300 focus:ring-blue-600 focus:border-blue-600 dark:focus:ring-blue-400"
    LABEL_VALID_CLASSES = "block text-sm font-medium leading-6 text-gray-900 dark:text-white"
    LABEL_INVALID_CLASSES = "block mb-2 text-sm font-medium text-red-700 dark:text-red-500"
    ERROR_MESSAGE_CLASSES = "mt-2 text-sm text-red-600 dark:text-red-500"
    CHECKBOX_CLASSES = "h-4 w-4 border-gray-300 rounded"

    def text_field(attribute, options = {}, &block)
      if options[:leading_icon]
        default_opts = {class: "#{classes_for_input(attribute, options)} pl-10"}

        text_layout(attribute) { leading_icon(&block) + super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
      else
        default_opts = {class: classes_for_input(attribute, options)}

        text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
      end
    end

    def email_field(attribute, options = {})
      default_opts = {class: classes_for_input(attribute, options)}

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def date_field(attribute, options = {})
      default_opts = {class: classes_for_input(attribute, options)}

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def password_field(attribute, options = {})
      default_opts = {class: classes_for_input(attribute, options)}

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def text_area(attribute, options = {})
      default_opts = {class: "mt-1 #{classes_for_input(attribute, options)}"}

      text_layout(attribute) { super(attribute, options.merge(default_opts)) } + attribute_error_message(attribute)
    end

    def label(attribute, text = nil, options = {}, &)
      default_opts = {class: classes_for_label(attribute, options)}

      super(attribute, text, options.merge(default_opts), &)
    end

    def check_box(attribute, options = {}, checked_value = "1", unchecked_value = "0")
      default_opts = {class: [CHECKBOX_CLASSES, options[:class]].compact.join(" ")}

      super(attribute, options.merge(default_opts), checked_value, unchecked_value)
    end

    def select(attribute, choices, options = {}, html_options = {})
      default_opts = {class: [SELECT_CLASSES, html_options[:class]].compact.join(" ")}

      super(attribute, choices, options, html_options.merge(default_opts))
    end

    private

    def classes_for_input(attribute, options)
      classes = if @object && @object.errors[attribute].present?
        INPUT_INVALID_CLASSES
      else
        INPUT_VALID_CLASSES
      end

      [classes, options[:class]].compact.join(" ")
    end

    def classes_for_label(attribute, options)
      classes = if @object && @object.errors[attribute].present?
        LABEL_INVALID_CLASSES
      else
        LABEL_VALID_CLASSES
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

      @template.content_tag :div, class: "pointer-events-none absolute inset-y-0 right-0 flex items-center pr-3 " do
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

      @template.content_tag :div, class: ERROR_MESSAGE_CLASSES do
        @object.errors[attribute].to_sentence.upcase_first
      end
    end
  end
end
