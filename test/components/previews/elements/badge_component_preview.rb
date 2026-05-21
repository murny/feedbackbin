# frozen_string_literal: true

module Elements
  # @label Badge
  class BadgeComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render Elements::BadgeComponent.new do
        "Badge"
      end
    end

    # @label Variants (semantic, token-driven)
    def variants
      render_with_template
    end

    # @label With Icon
    def with_icon
      render_with_template
    end

    # @label Tones (runtime color, solid vs soft side by side)
    def tones
      render_with_template
    end

    # @label With Dot
    def with_dot
      render_with_template
    end

    # @label As Link
    def as_link
      render Elements::BadgeComponent.new(href: "#", variant: :secondary) do
        "Clickable Badge"
      end
    end
  end
end
