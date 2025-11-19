# frozen_string_literal: true

module Ui
  # @label Badge
  class BadgeComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render Ui::BadgeComponent.new do
        "Badge"
      end
    end

    # @label Variants
    def variants
      render_with_template locals: {
        variants: Ui::BadgeComponent::VARIANTS
      }
    end

    # @label With Icon
    def with_icon
      render_with_template
    end

    # @label As Link
    def as_link
      render Ui::BadgeComponent.new(href: "#", variant: :secondary) do
        "Clickable Badge"
      end
    end

    # @label Custom Styled
    def custom_styled
      render Ui::BadgeComponent.new(
        variant: :default,
        class: "text-white font-medium",
        style: "background-color: #8B5CF6;"
      ) do
        "Custom Color"
      end
    end
  end
end
