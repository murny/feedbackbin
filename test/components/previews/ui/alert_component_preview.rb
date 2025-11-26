# frozen_string_literal: true

module Ui
  # @label Alert
  class AlertComponentPreview < Lookbook::Preview
    # @label Default
    def default
      render Ui::AlertComponent.new(
        title: "Heads up!",
        description: "You can add components to your app using the cli."
      )
    end

    # @label Destructive
    def destructive
      render Ui::AlertComponent.new(
        title: "Error",
        description: "Your session has expired. Please log in again.",
        variant: :destructive
      )
    end

    # @label All Variants
    def variants
      render_with_template
    end

    # @label With Block Content
    def with_block
      render_with_template
    end

    # @label Title Only
    def title_only
      render Ui::AlertComponent.new(
        title: "Quick notification"
      )
    end

    # @label Description Only
    def description_only
      render Ui::AlertComponent.new(
        description: "Something happened that you should know about."
      )
    end

    # @label Custom Icon
    def custom_icon
      render Ui::AlertComponent.new(
        title: "Custom Alert",
        description: "This uses a custom icon.",
        icon: "rocket"
      )
    end

    # @label No Icon
    def no_icon
      render Ui::AlertComponent.new(
        title: "Clean Alert",
        description: "This alert has no icon.",
        show_icon: false
      )
    end
  end
end
