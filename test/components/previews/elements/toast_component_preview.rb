# frozen_string_literal: true

module Elements
  # @label Toast
  class ToastComponentPreview < Lookbook::Preview
    # @label Default
    def default
      render_with_template
    end

    # @label All Variants
    def variants
      render_with_template
    end

    # @label Complex Examples
    def complex
      render_with_template
    end

    # @label Timing Options
    def timing
      render_with_template template: "ui/toast_component_preview/staggered"
    end
  end
end
