# frozen_string_literal: true

require "test_helper"

module Ui
  class ToastComponentTest < ViewComponent::TestCase
    # Content rendering
    test "renders toast with title and description" do
      render_inline(ToastComponent.new(
        title: "Notification",
        description: "Test message"
      ))

      assert_text "Notification"
      assert_text "Test message"
    end

    test "renders with title only" do
      render_inline(ToastComponent.new(title: "Title only"))

      assert_text "Title only"
    end

    test "renders with description only" do
      render_inline(ToastComponent.new(description: "Description only"))

      assert_text "Description only"
    end

    test "uses block content as description" do
      render_inline(ToastComponent.new(title: "Test")) do
        "Block content"
      end

      assert_text "Block content"
    end

    # Variants
    test "renders all variants without errors" do
      ToastComponent::VARIANTS.each do |variant|
        render_inline(ToastComponent.new(
          title: "Test",
          variant: variant
        ))

        assert_selector "[role='status']"
      end
    end

    test "raises error for invalid variant" do
      assert_raises(ArgumentError) do
        ToastComponent.new(variant: :invalid)
      end
    end

    # Icons
    test "shows icon by default" do
      render_inline(ToastComponent.new(
        title: "Test",
        variant: :success
      ))

      assert_selector "svg"
    end

    test "shows custom icon when provided" do
      render_inline(ToastComponent.new(
        title: "Test",
        icon: "rocket"
      ))

      assert_selector "svg"
    end

    test "hides icon when show_icon is false" do
      render_inline(ToastComponent.new(
        title: "Test",
        show_icon: false,
        dismissable: false
      ))

      assert_no_selector "svg"
    end

    # Dismiss button
    test "renders dismiss button when dismissable" do
      render_inline(ToastComponent.new(
        title: "Test",
        dismissable: true
      ))

      assert_selector "button[aria-label='Dismiss']"
    end

    test "does not render dismiss button when not dismissable" do
      render_inline(ToastComponent.new(
        title: "Test",
        dismissable: false
      ))

      assert_no_selector "button[aria-label='Dismiss']"
    end

    # Action button
    test "renders action button when both label and href provided" do
      render_inline(ToastComponent.new(
        title: "Test",
        action_label: "Click me",
        action_href: "/test"
      ))

      assert_selector "a[href='/test']", text: "Click me"
    end

    test "does not render action when only label provided" do
      render_inline(ToastComponent.new(
        title: "Test",
        action_label: "Click me"
      ))

      assert_no_selector "a", text: "Click me"
    end

    test "does not render action when only href provided" do
      render_inline(ToastComponent.new(
        title: "Test",
        action_href: "/test"
      ))

      assert_no_selector "a[href='/test']"
    end

    # Auto-dismiss timing
    test "sets custom dismiss_after timing" do
      render_inline(ToastComponent.new(
        title: "Test",
        dismiss_after: 3000
      ))

      assert_selector "[data-toast-dismiss-after-value='3000']"
    end

    test "does not set dismiss_after when zero" do
      render_inline(ToastComponent.new(
        title: "Test",
        dismiss_after: 0
      ))

      assert_no_selector "[data-toast-dismiss-after-value]"
    end

    # Accessibility
    test "has proper accessibility attributes" do
      render_inline(ToastComponent.new(title: "Test"))

      assert_selector "[role='status']"
      assert_selector "[aria-live='polite']"
      assert_selector "[aria-atomic='true']"
    end

    test "uses assertive aria-live for error variant" do
      render_inline(ToastComponent.new(
        title: "Test",
        variant: :error
      ))

      assert_selector "[aria-live='assertive']"
    end
  end
end
