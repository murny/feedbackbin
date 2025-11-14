# frozen_string_literal: true

module Ui
  # @label Button
  class ButtonComponentPreview < ViewComponent::Preview
    # @label Default
    def default
      render Ui::ButtonComponent.new do
        "Click me"
      end
    end

    # @label Variants
    def variants
      render_with_template locals: {
        variants: Ui::ButtonComponent::VARIANTS
      }
    end

    # @label Sizes
    def sizes
      render_with_template locals: {
        sizes: Ui::ButtonComponent::SIZES
      }
    end

    # @label Loading State
    def loading
      render Ui::ButtonComponent.new(loading: true) do
        "Loading..."
      end
    end

    # @label As Link
    def as_link
      render Ui::ButtonComponent.new(href: "#") do
        "I'm a Link"
      end
    end

    # @label With Icon
    def with_icon
      render Ui::ButtonComponent.new do
        safe_join([
          lucide_icon("mail", class: "mr-2"),
          "Email"
        ])
      end
    end

    # @label Icon Only
    def icon_only
      render Ui::ButtonComponent.new(size: :icon) do
        lucide_icon("chevron-right")
      end
    end

    # @label Disabled
    def disabled
      render Ui::ButtonComponent.new(disabled: true) do
        "Disabled"
      end
    end

    # @label Destructive
    def destructive
      render Ui::ButtonComponent.new(variant: :destructive) do
        "Delete Account"
      end
    end

    # @label Outline
    def outline
      render Ui::ButtonComponent.new(variant: :outline) do
        "Outline"
      end
    end

    # @label Secondary
    def secondary
      render Ui::ButtonComponent.new(variant: :secondary) do
        "Secondary"
      end
    end

    # @label Ghost
    def ghost
      render Ui::ButtonComponent.new(variant: :ghost) do
        "Ghost"
      end
    end

    # @label Link
    def link_variant
      render Ui::ButtonComponent.new(variant: :link) do
        "Link Style"
      end
    end
  end
end
