# frozen_string_literal: true

require "test_helper"

module Ui
  class ButtonComponentTest < ViewComponent::TestCase
    test "renders default button" do
      render_inline(ButtonComponent.new) { "Click me" }

      assert_selector "button", text: "Click me"
      assert_selector "button[type='button']"
    end

    test "renders all variants without errors" do
      ButtonComponent::VARIANTS.each do |variant|
        render_inline(ButtonComponent.new(variant: variant)) { "Test" }

        assert_selector "button, a"
      end
    end

    test "renders all sizes without errors" do
      ButtonComponent::SIZES.each do |size|
        render_inline(ButtonComponent.new(size: size)) { "Test" }

        assert_selector "button, a"
      end
    end

    test "renders as link when href provided" do
      render_inline(ButtonComponent.new(href: "/test")) { "Link" }

      assert_selector "a[href='/test']", text: "Link"
      assert_no_selector "button"
    end

    test "renders as button when no href" do
      render_inline(ButtonComponent.new) { "Button" }

      assert_selector "button", text: "Button"
      assert_no_selector "a"
    end

    test "shows loading spinner when loading" do
      render_inline(ButtonComponent.new(loading: true)) { "Loading" }

      assert_selector ".animate-spin"
      assert_selector "button[disabled]"
    end

    test "merges custom classes" do
      render_inline(ButtonComponent.new(class: "custom-class")) { "Test" }

      assert_selector "button.custom-class"
    end

    test "sets disabled attribute" do
      render_inline(ButtonComponent.new(disabled: true)) { "Test" }

      assert_selector "button[disabled]"
    end

    test "sets custom type attribute" do
      render_inline(ButtonComponent.new(type: :submit)) { "Submit" }

      assert_selector "button[type='submit']"
    end

    test "raises error for invalid variant" do
      assert_raises(ArgumentError) do
        ButtonComponent.new(variant: :invalid)
      end
    end

    test "raises error for invalid size" do
      assert_raises(ArgumentError) do
        ButtonComponent.new(size: :invalid)
      end
    end

    test "includes base accessibility classes" do
      render_inline(ButtonComponent.new) { "Test" }

      page_html = page.native.to_html

      assert_includes page_html, "focus-visible:"
      assert_includes page_html, "disabled:"
    end

    test "works with data attributes" do
      render_inline(ButtonComponent.new(data: { action: "click->test#handler" })) { "Test" }

      assert_selector "button[data-action='click->test#handler']"
    end
  end
end
