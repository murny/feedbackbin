# frozen_string_literal: true

module Components
  module FormHelper
    def render_form_with(**options, &block)
      # Extract custom options
      classes = options.delete(:class) || ""

      # Set default form classes with shadcn styling
      base_classes = "space-y-6"
      options[:class] = tw_merge(base_classes, classes)

      # Use our CustomFormBuilder
      options[:builder] = FormBuilders::CustomFormBuilder

      form_with(**options, &block)
    end

    def render_form_for(record, **options, &block)
      # Extract custom options
      classes = options.delete(:class) || ""

      # Set default form classes with shadcn styling
      base_classes = "space-y-6"
      options[:class] = tw_merge(base_classes, classes)

      # Use our CustomFormBuilder
      options[:builder] = FormBuilders::CustomFormBuilder

      form_for(record, **options, &block)
    end
  end
end
