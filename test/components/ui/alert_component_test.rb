# frozen_string_literal: true

require "test_helper"

module Ui
  class AlertComponentTest < ViewComponent::TestCase
    test "renders default alert with title and description" do
      render_inline(AlertComponent.new(
        title: "Test Title",
        description: "Test Description"
      ))

      assert_selector "div[role='alert']", text: "Test Title"
      assert_selector "div[data-slot='alert-title']", text: "Test Title"
      assert_selector "div[data-slot='alert-description']", text: "Test Description"
    end

    test "renders all variants without errors" do
      AlertComponent::VARIANTS.each do |variant|
        render_inline(AlertComponent.new(
          title: "Test",
          description: "Test",
          variant: variant
        ))

        assert_selector "div[role='alert']"
      end
    end

    test "renders destructive variant with correct classes" do
      render_inline(AlertComponent.new(
        title: "Error",
        variant: :destructive
      ))

      assert_selector "div.text-destructive"
    end

    test "renders default icon based on variant" do
      render_inline(AlertComponent.new(
        title: "Test",
        variant: :default
      ))

      # Should have info icon
      assert_selector "svg"
    end

    test "renders destructive icon for destructive variant" do
      render_inline(AlertComponent.new(
        title: "Error",
        variant: :destructive
      ))

      # Should have circle-alert icon
      assert_selector "svg"
    end

    test "renders custom icon when provided" do
      render_inline(AlertComponent.new(
        title: "Test",
        icon: "rocket"
      ))

      assert_selector "svg"
    end

    test "does not render icon when show_icon is false" do
      render_inline(AlertComponent.new(
        title: "Test",
        show_icon: false
      ))

      assert_no_selector "svg"
    end

    test "renders description from block" do
      render_inline(AlertComponent.new(title: "Test")) do
        "Block Description"
      end

      assert_selector "div[data-slot='alert-description']", text: "Block Description"
    end

    test "renders with only title" do
      render_inline(AlertComponent.new(title: "Just Title"))

      assert_selector "div[data-slot='alert-title']", text: "Just Title"
      assert_no_selector "div[data-slot='alert-description']"
    end

    test "renders with only description" do
      render_inline(AlertComponent.new(description: "Just Description"))

      assert_selector "div[data-slot='alert-description']", text: "Just Description"
      assert_no_selector "div[data-slot='alert-title']"
    end

    test "merges custom classes" do
      render_inline(AlertComponent.new(
        title: "Test",
        class: "custom-class"
      ))

      assert_selector "div.custom-class[role='alert']"
    end

    test "raises error for invalid variant" do
      assert_raises(ArgumentError) do
        AlertComponent.new(variant: :invalid)
      end
    end

    test "includes accessibility role" do
      render_inline(AlertComponent.new(
        title: "Test"
      ))

      assert_selector "div[role='alert']"
    end

    test "renders with data slots for styling hooks" do
      render_inline(AlertComponent.new(
        title: "Test Title",
        description: "Test Description"
      ))

      assert_selector "[data-slot='alert-title']"
      assert_selector "[data-slot='alert-description']"
    end

    test "block content overrides description parameter" do
      render_inline(AlertComponent.new(
        title: "Test",
        description: "This should be overridden"
      )) do
        "Block Content"
      end

      assert_selector "div[data-slot='alert-description']", text: "Block Content"
      assert_no_text "This should be overridden"
    end

    test "renders without title or description" do
      # Edge case - alert with only icon
      render_inline(AlertComponent.new)

      assert_selector "div[role='alert']"
      # Should still have icon by default
      assert_selector "svg"
    end

    test "applies grid layout classes" do
      render_inline(AlertComponent.new(title: "Test"))

      page_html = page.native.to_html

      # Check for grid classes
      assert_includes page_html, "grid"
    end
  end
end
