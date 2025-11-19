# frozen_string_literal: true

module Ui
  # @label Toast
  class ToastComponentPreview < Lookbook::Preview
    # @label Default
    def default
      render Ui::ToastComponent.new(
        title: "Notification",
        description: "Your changes have been saved."
      )
    end

    # @label Success
    def success
      render Ui::ToastComponent.new(
        title: "Success",
        description: "Your message has been sent successfully.",
        variant: :success
      )
    end

    # @label Warning
    def warning
      render Ui::ToastComponent.new(
        title: "Warning",
        description: "You have unsaved changes that will be lost.",
        variant: :warning
      )
    end

    # @label Error
    def error
      render Ui::ToastComponent.new(
        title: "Error",
        description: "Something went wrong. Please try again.",
        variant: :error
      )
    end

    # @label Info
    def info
      render Ui::ToastComponent.new(
        title: "Information",
        description: "A new version is available. Refresh to update.",
        variant: :info
      )
    end

    # @label All Variants
    def variants
      render_with_template locals: {
        variants: Ui::ToastComponent::VARIANTS
      }
    end

    # @label With Action
    def with_action
      render Ui::ToastComponent.new(
        title: "Update Available",
        description: "A new version of the app is ready.",
        variant: :info,
        action_label: "Update now",
        action_href: "#"
      )
    end

    # @label Title Only
    def title_only
      render Ui::ToastComponent.new(
        title: "Changes saved"
      )
    end

    # @label Description Only
    def description_only
      render Ui::ToastComponent.new(
        description: "Your profile has been updated successfully."
      )
    end

    # @label Custom Icon
    def custom_icon
      render Ui::ToastComponent.new(
        title: "Rocket Launch",
        description: "Your project has been deployed.",
        icon: "rocket",
        variant: :success
      )
    end

    # @label No Icon
    def no_icon
      render Ui::ToastComponent.new(
        title: "Clean Notification",
        description: "This toast has no icon.",
        show_icon: false
      )
    end

    # @label Not Dismissable
    def not_dismissable
      render Ui::ToastComponent.new(
        title: "Important",
        description: "This notification cannot be dismissed manually.",
        dismissable: false,
        dismiss_after: 0
      )
    end

    # @label Long Auto-dismiss
    def long_dismiss
      render Ui::ToastComponent.new(
        title: "Scheduled",
        description: "This will auto-dismiss after 10 seconds.",
        dismiss_after: 10000
      )
    end

    # @label Delayed Show
    def delayed_show
      render Ui::ToastComponent.new(
        title: "Delayed Toast",
        description: "This toast appears after a 2 second delay.",
        show_delay: 2000
      )
    end

    # @label Staggered Toasts
    def staggered
      render_with_template
    end

    # @label With Block Content
    def with_block
      render_with_template
    end

    # @label Complex Example
    def complex
      render_with_template
    end
  end
end
