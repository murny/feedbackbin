# frozen_string_literal: true

require "test_helper"

module Ui
  class ToastComponentTest < ViewComponent::TestCase
    test "renders default toast" do
      render_inline(ToastComponent.new(
        title: "Notification",
        description: "Test message"
      ))

      assert_selector "[role='status']"
      assert_text "Notification"
      assert_text "Test message"
    end

    test "renders all variants without errors" do
      ToastComponent::VARIANTS.each do |variant|
        render_inline(ToastComponent.new(
          title: "Test",
          description: "Test message",
          variant: variant
        ))

        assert_selector "[role='status']"
      end
    end

    test "renders with title only" do
      render_inline(ToastComponent.new(title: "Title only"))

      assert_text "Title only"
      assert_no_text "description"
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

    test "shows default icon for each variant" do
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
        dismissable: false  # Also disable dismiss button to avoid its icon
      ))

      assert_no_selector "svg"
    end

    test "renders dismiss button when dismissable" do
      render_inline(ToastComponent.new(
        title: "Test",
        dismissable: true
      ))

      assert_selector "button[aria-label='Close']"
    end

    test "does not render dismiss button when not dismissable" do
      render_inline(ToastComponent.new(
        title: "Test",
        dismissable: false
      ))

      assert_no_selector "button[aria-label='Close']"
    end

    test "renders action button when action provided" do
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

    test "has toast stimulus controller" do
      render_inline(ToastComponent.new(title: "Test"))

      assert_selector "[data-controller='toast']"
    end

    test "sets dismiss_after value for stimulus" do
      render_inline(ToastComponent.new(
        title: "Test",
        dismiss_after: 3000
      ))

      assert_selector "[data-toast-dismiss-after-value='3000']"
    end

    test "sets default dismiss_after value" do
      render_inline(ToastComponent.new(title: "Test"))

      assert_selector "[data-toast-dismiss-after-value='5000']"
    end

    test "does not set dismiss_after when zero" do
      render_inline(ToastComponent.new(
        title: "Test",
        dismiss_after: 0
      ))

      assert_no_selector "[data-toast-dismiss-after-value]"
    end

    test "has accessibility attributes" do
      render_inline(ToastComponent.new(title: "Test"))

      assert_selector "[role='status']"
      assert_selector "[aria-live='polite']"
      assert_selector "[aria-atomic='true']"
    end

    test "applies success variant classes" do
      render_inline(ToastComponent.new(
        title: "Test",
        variant: :success
      ))

      page_html = page.native.to_html

      assert_includes page_html, "border-l-green-500"
    end

    test "applies warning variant classes" do
      render_inline(ToastComponent.new(
        title: "Test",
        variant: :warning
      ))

      page_html = page.native.to_html

      assert_includes page_html, "border-l-yellow-500"
    end

    test "applies error variant classes" do
      render_inline(ToastComponent.new(
        title: "Test",
        variant: :error
      ))

      page_html = page.native.to_html

      assert_includes page_html, "border-l-destructive"
    end

    test "applies info variant classes" do
      render_inline(ToastComponent.new(
        title: "Test",
        variant: :info
      ))

      page_html = page.native.to_html

      assert_includes page_html, "border-l-primary"
    end

    test "merges custom classes" do
      render_inline(ToastComponent.new(
        title: "Test",
        class: "custom-class"
      ))

      assert_selector ".custom-class"
    end

    test "raises error for invalid variant" do
      assert_raises(ArgumentError) do
        ToastComponent.new(variant: :invalid)
      end
    end

    test "works with data attributes" do
      render_inline(ToastComponent.new(
        title: "Test",
        data: { testid: "custom-toast" }
      ))

      assert_selector "[data-testid='custom-toast']"
    end

    test "has close action bound to stimulus" do
      render_inline(ToastComponent.new(title: "Test"))

      assert_selector "[data-action='toast#close']"
    end

    test "dismiss button has stimulus close action" do
      render_inline(ToastComponent.new(
        title: "Test",
        dismissable: true
      ))

      assert_selector "button[data-action='toast#close']"
    end

    test "has pause and resume actions on hover" do
      render_inline(ToastComponent.new(title: "Test"))

      page_html = page.native.to_html

      assert_includes page_html, "mouseenter-&gt;toast#pause"
      assert_includes page_html, "mouseleave-&gt;toast#resume"
    end

    test "uses assertive aria-live for error variant" do
      render_inline(ToastComponent.new(
        title: "Test",
        variant: :error
      ))

      assert_selector "[aria-live='assertive']"
    end

    test "uses polite aria-live for non-error variants" do
      render_inline(ToastComponent.new(
        title: "Test",
        variant: :success
      ))

      assert_selector "[aria-live='polite']"
    end
  end
end
