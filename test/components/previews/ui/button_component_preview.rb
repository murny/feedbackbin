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
      render_with_template
    end

    # @label Sizes
    def sizes
      render_with_template
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
      render_with_template
    end

    # @label Icon Only
    def icon_only
      render_with_template
    end

    # @label Disabled
    def disabled
      render Ui::ButtonComponent.new(disabled: true) do
        "Disabled"
      end
    end
  end
end
